.PHONY: run prod down clean cli migrate prune

DC=docker compose

run: 
	@echo "🚀 Starting development environment..."
	$(DC) up -d app prisma-studio  
	@echo "📱 Next.js is available at http://localhost:3000"
	@echo "🔧 Prisma Studio is available at http://localhost:5555"
	@$(DC) logs -f app

prod:
	@echo "🚀 Starting production environment..."
	$(DC) build app  # Rebuild uniquement l'image "app" quand nécessaire
	$(DC) up -d app
	@echo "🌐 Production environment is running at http://localhost:3000"

migrate:
	@echo "🔄 Running database migrations..."
	$(DC) exec app sh -c "npx prisma migrate deploy && npx prisma generate"
	@echo "✅ Migrations complete!"

cli:
	@echo "🛠️  Entering app container..."
	$(DC) exec app sh

down:
	@echo "🛑 Stopping all services..."
	$(DC) down

prune:
	@echo "🧹 Cleaning up Docker resources..."
	@docker system prune -f
	@docker image prune -f
	@echo "✅ Docker cleanup complete!"

clean: down prune
	@echo "🧹 Cleaning up project..."
	@sudo rm -rf node_modules .next dist
	@echo "✅ Project cleanup complete!"
