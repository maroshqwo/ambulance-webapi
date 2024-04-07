#!/bin/zsh

# Parse command line arguments
command=${1:-start}  # Default to "start" if no argument is provided

# Set the project root directory
ProjectRoot="$(dirname $0)/.."

# Set environment variables
export AMBULANCE_API_ENVIRONMENT="Development"
export AMBULANCE_API_PORT="8080"
export AMBULANCE_API_MONGODB_USERNAME="root"
export AMBULANCE_API_MONGODB_PASSWORD="neUhaDnes"

# Define a function for managing MongoDB using Docker Compose
mongo() {
    docker compose --file "${ProjectRoot}/deployments/docker-compose/compose.yaml" "$@"
}

# Execute commands based on the input argument
case $command in
  start)
    # Use trap to ensure MongoDB is shut down even if the script exits prematurely
    trap 'mongo down' EXIT
    mongo up --detach
    go run "${ProjectRoot}/cmd/ambulance-api-service"
    mongo down  # This line is likely redundant due to the trap, but included for explicitness
    ;;
  mongo)
    mongo up
    ;;
  test)
    go test -v ./...
    ;;
  openapi)
    docker run --rm -ti -v "${ProjectRoot}:/local" openapitools/openapi-generator-cli generate -c /local/scripts/generator-cfg.yaml
    ;;
  docker)
    docker build -t maroshqwo/ambulance-wl-webapi:local-build -f "${ProjectRoot}/build/docker/Dockerfile" .
    ;;
  *)
    echo "Unknown command: $command" >&2
    exit 1
    ;;
esac

