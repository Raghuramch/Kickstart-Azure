import io
import json
import re
import uuid
import zipfile
from pathlib import Path

from flask import Flask, jsonify, render_template, request, send_file


app = Flask(__name__)
TEMPLATES = Path(__file__).parent / "bundle_templates"


@app.get("/")
def home():
    return render_template("index.html", values={}, errors=[])


@app.post("/", endpoint="generate_legacy")
@app.post("/generate", endpoint="generate")
@app.post("/preview", endpoint="preview")
def generate():
    values = {key: request.form.get(key, "").strip() for key in (
        "subscription", "resource_group", "location", "vm_size",
        "admin_username", "ssh_public_key", "vms", "tags",
    )}
    errors = []
    try:
        uuid.UUID(values["subscription"])
    except ValueError:
        errors.append("Enter a valid Azure subscription ID (UUID).")
    if not re.fullmatch(r"[A-Za-z0-9_.()-]{1,90}", values["resource_group"]):
        errors.append("Resource group must be 1–90 characters using letters, numbers, _, -, ., (, or ).")
    if not re.fullmatch(r"[a-z0-9-]{2,40}", values["location"]):
        errors.append("Enter an Azure region such as eastus or westus2.")
    if not re.fullmatch(r"Standard_[A-Za-z0-9_]{1,40}", values["vm_size"]):
        errors.append("Enter a VM size such as Standard_B1s.")
    if not re.fullmatch(r"[A-Za-z][A-Za-z0-9_-]{0,31}", values["admin_username"]):
        errors.append("Admin username must start with a letter and be at most 32 characters.")
    if not values["ssh_public_key"].startswith(("ssh-rsa ", "ssh-ed25519 ")):
        errors.append("Paste an ssh-rsa or ssh-ed25519 public key.")

    vm_names = [line.strip() for line in values["vms"].splitlines() if line.strip()]
    if not vm_names or len(vm_names) > 20:
        errors.append("Enter 1–20 VM names, one per line.")
    elif any(not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9-]{0,63}", name) or name.endswith("-") for name in vm_names):
        errors.append("VM names must be 1–64 letters, numbers, or hyphens, with no trailing hyphen.")
    elif len({name.lower() for name in vm_names}) != len(vm_names):
        errors.append("VM names must be unique.")

    tags = {}
    for line in values["tags"].splitlines():
        if not line.strip():
            continue
        if "=" not in line:
            errors.append("Each tag must use key=value on its own line.")
            break
        key, value = (part.strip() for part in line.split("=", 1))
        if not key or not value:
            errors.append("Tag keys and values cannot be empty.")
            break
        tags[key] = value
    if errors:
        if request.path == "/preview":
            return jsonify(errors=errors), 400
        return render_template("index.html", values=values, errors=errors), 400

    terraform_values = {
        "subscription_id": values["subscription"],
        "resource_group_name": values["resource_group"],
        "location": values["location"],
        "vm_size": values["vm_size"],
        "admin_username": values["admin_username"],
        "ssh_public_key": values["ssh_public_key"],
        "vm_names": vm_names,
        "tags": tags,
    }
    export_config = {
        "subscription_id": values["subscription"],
        "resource_group_name": values["resource_group"],
        "vm_names": vm_names,
    }
    files = {
        filename: (TEMPLATES / filename).read_text(encoding="utf-8")
        for filename in (
            "main.tf", "variables.tf", "outputs.tf", "export_vm_tags.py",
            "export_requirements.txt", "README.md",
            ".github/workflows/terraform-plan.yml",
            ".github/workflows/terraform-apply.yml",
            ".github/workflows/export-vm-tags.yml",
            ".github/scripts/terraform-ci.sh",
        )
    }
    files["terraform.tfvars.json"] = json.dumps(terraform_values, indent=2) + "\n"
    files["export_config.json"] = json.dumps(export_config, indent=2) + "\n"
    files[".gitignore"] = ".terraform/\n*.tfstate\n*.tfstate.*\n*.tfplan\n*.xlsx\n.venv/\n__pycache__/\n"
    if request.path == "/preview":
        return jsonify(files=files)

    archive = io.BytesIO()
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED) as bundle:
        for filename, content in files.items():
            bundle.writestr(filename, content)
    archive.seek(0)
    return send_file(archive, as_attachment=True, download_name="azure-vm-tag-project.zip", mimetype="application/zip")


if __name__ == "__main__":
    app.run(debug=True)
