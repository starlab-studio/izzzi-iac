.PHONY: help init-dev init-prod plan-dev plan-prod apply-dev apply-prod destroy-dev destroy-prod
.PHONY: ansible-init-dev ansible-init-prod ansible-deploy-dev ansible-deploy-prod
.PHONY: ansible-backup-dev ansible-backup-prod ansible-rollback-dev ansible-rollback-prod
.PHONY: ansible-scale-dev ansible-scale-prod full-deploy-dev full-deploy-prod

# Colors for output
CYAN := \033[0;36m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m# No Color

help: ## Show this help message
	@echo "$(CYAN)===================================$(NC)"
	@echo "$(GREEN)    IZZZI Infrastructure Commands$(NC)"
	@echo "$(CYAN)===================================$(NC)"
	@echo ""
	@echo "$(YELLOW)Terraform Commands:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '(init|plan|apply|destroy)' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(CYAN)%-25s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Ansible Commands:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E 'ansible' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(CYAN)%-25s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Full Deployment:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E 'full-deploy' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(CYAN)%-25s$(NC) %s\n", $$1, $$2}'
	@echo ""

# ============================================
# Terraform Commands - DEV
# ============================================

init-dev: ## Initialize Terraform for DEV environment
	@echo "$(GREEN)Initializing Terraform for DEV...$(NC)"
	cd terraform/envs/dev && terraform init

plan-dev: ## Plan Terraform changes for DEV
	@echo "$(GREEN)Planning Terraform changes for DEV...$(NC)"
	cd terraform/envs/dev && terraform plan -out=tfplan

apply-dev: ## Apply Terraform changes for DEV
	@echo "$(GREEN)Applying Terraform changes for DEV...$(NC)"
	cd terraform/envs/dev && terraform apply tfplan

destroy-dev: ## Destroy Terraform infrastructure for DEV
	@echo "$(RED)Destroying DEV infrastructure...$(NC)"
	@echo "$(YELLOW)WARNING: This will destroy all resources!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		cd terraform/envs/dev && terraform destroy; \
	fi

output-dev: ## Show Terraform outputs for DEV
	@cd terraform/envs/dev && terraform output

# ============================================
# Terraform Commands - PRODUCTION
# ============================================

init-prod: ## Initialize Terraform for PRODUCTION
	@echo "$(GREEN)Initializing Terraform for PRODUCTION...$(NC)"
	cd terraform/envs/prod && terraform init

plan-prod: ## Plan Terraform changes for PRODUCTION
	@echo "$(GREEN)Planning Terraform changes for PRODUCTION...$(NC)"
	cd terraform/envs/prod && terraform plan -out=tfplan

apply-prod: ## Apply Terraform changes for PRODUCTION
	@echo "$(GREEN)Applying Terraform changes for PRODUCTION...$(NC)"
	@echo "$(YELLOW)WARNING: Deploying to PRODUCTION!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		cd terraform/envs/prod && terraform apply tfplan; \
	fi

destroy-prod: ## Destroy Terraform infrastructure for PRODUCTION
	@echo "$(RED)Destroying PRODUCTION infrastructure...$(NC)"
	@echo "$(RED)CRITICAL WARNING: This will destroy all production resources!$(NC)"
	@read -p "Type 'destroy-production' to confirm: " confirm; \
	if [ "$$confirm" = "destroy-production" ]; then \
		cd terraform/envs/prod && terraform destroy; \
	else \
		echo "$(RED)Destruction cancelled.$(NC)"; \
	fi

output-prod: ## Show Terraform outputs for PRODUCTION
	@cd terraform/envs/prod && terraform output

# ============================================
# Ansible Commands - DEV
# ============================================

ansible-init-dev: ## Initialize Docker Swarm cluster (DEV)
	@echo "$(GREEN)Initializing Docker Swarm cluster for DEV...$(NC)"
	cd ansible && ansible-playbook playbooks/init-cluster.yml -i inventory/dev.yml

ansible-deploy-dev: ## Deploy application stack (DEV)
	@echo "$(GREEN)Deploying application stack to DEV...$(NC)"
	cd ansible && ansible-playbook playbooks/deploy.yml -i inventory/dev.yml

ansible-deploy-dev-tag: ## Deploy with specific image tag (DEV) - Usage: make ansible-deploy-dev-tag TAG=v1.2.3
	@echo "$(GREEN)Deploying application stack to DEV with tag: $(TAG)$(NC)"
	cd ansible && ansible-playbook playbooks/deploy.yml -i inventory/dev.yml -e "image_tag=$(TAG)"

ansible-backup-dev: ## Backup PostgreSQL database (DEV)
	@echo "$(GREEN)Backing up database for DEV...$(NC)"
	cd ansible && ansible-playbook playbooks/backup.yml -i inventory/dev.yml

ansible-rollback-dev: ## Rollback service (DEV) - Usage: make ansible-rollback-dev SERVICE=frontend
	@echo "$(GREEN)Rolling back service $(SERVICE) in DEV...$(NC)"
	cd ansible && ansible-playbook playbooks/rollback.yml -i inventory/dev.yml -e "service=$(SERVICE)"

ansible-scale-dev: ## Scale service (DEV) - Usage: make ansible-scale-dev SERVICE=backend REPLICAS=3
	@echo "$(GREEN)Scaling service $(SERVICE) to $(REPLICAS) replicas in DEV...$(NC)"
	cd ansible && ansible-playbook playbooks/scale.yml -i inventory/dev.yml -e "service=$(SERVICE) replicas=$(REPLICAS)"

ansible-site-dev: ## Run full site playbook (DEV)
	@echo "$(GREEN)Running full site playbook for DEV...$(NC)"
	cd ansible && ansible-playbook playbooks/site.yml -i inventory/dev.yml

# ============================================
# Ansible Commands - PRODUCTION
# ============================================

ansible-init-prod: ## Initialize Docker Swarm cluster (PRODUCTION)
	@echo "$(GREEN)Initializing Docker Swarm cluster for PRODUCTION...$(NC)"
	@echo "$(YELLOW)WARNING: Deploying to PRODUCTION!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		cd ansible && \
		echo "$(YELLOW)Step 1/2: Cleaning up conflicting Docker sources...$(NC)" && \
		ansible-playbook playbooks/cleanup-docker-sources.yml -i inventory/prod.yml && \
		echo "$(GREEN)Step 2/2: Initializing Docker Swarm cluster...$(NC)" && \
		ansible-playbook playbooks/init-cluster.yml -i inventory/prod.yml; \
	fi

ansible-deploy-prod: ## Deploy application stack (PRODUCTION)
	@echo "$(GREEN)Deploying application stack to PRODUCTION...$(NC)"
	@echo "$(YELLOW)WARNING: Deploying to PRODUCTION!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		cd ansible && ansible-playbook playbooks/deploy.yml -i inventory/prod.yml; \
	fi

ansible-deploy-prod-tag: ## Deploy with specific image tag (PRODUCTION) - Usage: make ansible-deploy-prod-tag TAG=v1.2.3
	@echo "$(GREEN)Deploying application stack to PRODUCTION with tag: $(TAG)$(NC)"
	@echo "$(YELLOW)WARNING: Deploying to PRODUCTION!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		cd ansible && ansible-playbook playbooks/deploy.yml -i inventory/prod.yml -e "image_tag=$(TAG)"; \
	fi

ansible-backup-prod: ## Backup PostgreSQL database (PRODUCTION)
	@echo "$(GREEN)Backing up database for PRODUCTION...$(NC)"
	cd ansible && ansible-playbook playbooks/backup.yml -i inventory/prod.yml

ansible-rollback-prod: ## Rollback service (PRODUCTION) - Usage: make ansible-rollback-prod SERVICE=frontend
	@echo "$(GREEN)Rolling back service $(SERVICE) in PRODUCTION...$(NC)"
	@echo "$(YELLOW)WARNING: Rolling back in PRODUCTION!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		cd ansible && ansible-playbook playbooks/rollback.yml -i inventory/prod.yml -e "service=$(SERVICE)"; \
	fi

ansible-scale-prod: ## Scale service (PRODUCTION) - Usage: make ansible-scale-prod SERVICE=backend REPLICAS=3
	@echo "$(GREEN)Scaling service $(SERVICE) to $(REPLICAS) replicas in PRODUCTION...$(NC)"
	@echo "$(YELLOW)WARNING: Scaling in PRODUCTION!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		cd ansible && ansible-playbook playbooks/scale.yml -i inventory/prod.yml -e "service=$(SERVICE) replicas=$(REPLICAS)"; \
	fi

ansible-site-prod: ## Run full site playbook (PRODUCTION)
	@echo "$(GREEN)Running full site playbook for PRODUCTION...$(NC)"
	@echo "$(YELLOW)WARNING: Deploying to PRODUCTION!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		cd ansible && ansible-playbook playbooks/site.yml -i inventory/prod.yml; \
	fi

# ============================================
# Full Deployment Workflows
# ============================================

full-deploy-dev: init-dev plan-dev apply-dev ansible-init-dev ansible-deploy-dev ## Full deployment: Terraform + Ansible (DEV)
	@echo "$(GREEN)Full DEV deployment completed!$(NC)"

full-deploy-prod: init-prod plan-prod apply-prod ansible-init-prod ansible-deploy-prod ## Full deployment: Terraform + Ansible (PRODUCTION)
	@echo "$(GREEN)Full PRODUCTION deployment completed!$(NC)"

# ============================================
# Utility Commands
# ============================================

ansible-ping-dev: ## Test Ansible connectivity (DEV)
	@echo "$(GREEN)Testing Ansible connectivity for DEV...$(NC)"
	cd ansible && ansible all -i inventory/dev.yml -m ping

ansible-ping-prod: ## Test Ansible connectivity (PRODUCTION)
	@echo "$(GREEN)Testing Ansible connectivity for PRODUCTION...$(NC)"
	cd ansible && ansible all -i inventory/prod.yml -m ping

clean: ## Clean Terraform plans and temporary files
	@echo "$(GREEN)Cleaning temporary files...$(NC)"
	find terraform/envs -name "tfplan" -delete
	find terraform/envs -name ".terraform.lock.hcl" -delete
	@echo "$(GREEN)Clean complete!$(NC)"

