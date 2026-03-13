.PHONY: setup deploy infra-up infra-down apps-up apps-down logs vault-encrypt vault-edit

# === Ansible ===

setup:
	cd ansible && ansible-playbook playbooks/setup.yml --ask-vault-pass --ask-become-pass

deploy:
	cd ansible && ansible-playbook playbooks/deploy.yml --ask-vault-pass --ask-become-pass $(if $(service),-e "service=$(service)") $(if $(tag),-e "tag=$(tag)")

vault-encrypt:
	ansible-vault encrypt ansible/group_vars/all/vault.yml

vault-edit:
	ansible-vault edit ansible/group_vars/all/vault.yml

vault-decrypt:
	ansible-vault decrypt ansible/group_vars/all/vault.yml

# === Local Docker Compose (for testing) ===

infra-up:
	docker compose -f docker/docker-compose.infra.yml --env-file .env up -d

infra-down:
	docker compose -f docker/docker-compose.infra.yml --env-file .env down

apps-up:
	docker compose -f docker/docker-compose.yml --env-file .env up -d

apps-down:
	docker compose -f docker/docker-compose.yml --env-file .env down

logs:
	docker compose -f docker/docker-compose.yml --env-file .env logs -f $(if $(service),$(service),)

ps:
	docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
