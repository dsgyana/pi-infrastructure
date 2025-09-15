#!/bin/bash
# Database Management Script for Pi Infrastructure
# Usage: ./manage-databases.sh [add|remove|list] [database_name] [username] [password]

set -e

CONTAINER_NAME="pi_shared_postgres"
ADMIN_USER="pi_admin"

# Function to add a new database
add_database() {
    local db_name=$1
    local db_user=$2
    local db_password=$3
    
    if [ -z "$db_name" ] || [ -z "$db_user" ] || [ -z "$db_password" ]; then
        echo "Usage: $0 add <database_name> <username> <password>"
        exit 1
    fi
    
    echo "🔄 Adding database: $db_name with user: $db_user"
    
    # Create database and user
    echo "Creating database: $db_name"
    docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d postgres -c "CREATE DATABASE $db_name;"
    
    echo "Creating user: $db_user"
    docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d postgres -c "CREATE USER $db_user WITH ENCRYPTED PASSWORD '$db_password';"
    
    echo "Granting privileges on database"
    docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d postgres -c "GRANT ALL PRIVILEGES ON DATABASE $db_name TO $db_user;"
    
    # Set permissions on the database
    echo "Setting schema permissions"
    docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $db_name -c "GRANT ALL ON SCHEMA public TO $db_user;"
    docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $db_name -c "GRANT ALL ON ALL TABLES IN SCHEMA public TO $db_user;"
    docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $db_name -c "GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO $db_user;"
    docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $db_name -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $db_user;"
    docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d $db_name -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $db_user;"
    
    echo "✅ Database $db_name created successfully!"
    
    # Test connection
    echo "🔍 Testing connection..."
    docker exec -i $CONTAINER_NAME psql -U $db_user -d $db_name -c "SELECT current_database(), current_user;" || echo "⚠️  Connection test failed"
}

# Function to remove a database
remove_database() {
    local db_name=$1
    local db_user=$2
    
    if [ -z "$db_name" ] || [ -z "$db_user" ]; then
        echo "Usage: $0 remove <database_name> <username>"
        exit 1
    fi
    
    echo "🗑️  Removing database: $db_name and user: $db_user"
    
    docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d postgres -c "DROP DATABASE IF EXISTS $db_name;"
    docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d postgres -c "DROP USER IF EXISTS $db_user;"
    
    echo "✅ Database $db_name removed successfully!"
}

# Function to list databases
list_databases() {
    echo "📋 Current databases:"
    docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d postgres -c "\l"
    echo ""
    echo "👥 Current users:"
    docker exec -i $CONTAINER_NAME psql -U $ADMIN_USER -d postgres -c "\du"
}

# Main command handler
case "$1" in
    add)
        add_database "$2" "$3" "$4"
        ;;
    remove)
        remove_database "$2" "$3"
        ;;
    list)
        list_databases
        ;;
    *)
        echo "Usage: $0 {add|remove|list} [args...]"
        echo ""
        echo "Examples:"
        echo "  $0 add expense_tracker expense_user mypassword"
        echo "  $0 add new_app_db newapp_user newpassword"
        echo "  $0 remove old_db old_user"
        echo "  $0 list"
        exit 1
        ;;
esac