#!/bin/zsh

###########################
# This script creates a new
# .NET fullstack project
# with my typical setup.
# Webapi, Anuglar, EF Core
###########################

###########################
# Misc settings
###########################

# Color codes for output
RED="\e[31m" # Errors
YELLOW="\e[33m" # Warnings
GREEN="\e[32m" # Success
ENDCOLOR="\e[0m" # Reset

###########################
# Prerequisites
###########################

PROJ_NAME=$1
DB_PROVIDER=$2

# Check if commandline args are given
if [ $# -eq 0 ]; then
    echo -e "${RED}Please specifiy the project name 'dnc <projectname>' and run the script again.${ENDCOLOR}"
    exit 1
fi

# Check if a -h or --help flag is given
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo -e "Usage: dnc <projectname> <dbprovider>"
    echo -e "Example: dnc MyProject sqlite"
    exit 0
fi

# If the second argument is not given, default to SqlServer
if [ -z "$DB_PROVIDER" ]; then
    DB_PROVIDER="mssql"
    echo -e "${YELLOW}No database provider specified. Defaulting to SqlServer.${ENDCOLOR}"
fi

# Check if dotnet is installed
if ! command -v dotnet &> /dev/null
then
    echo -e "${RED}dotnet could not be found. Please install it and run the script again.${ENDCOLOR}"
    exit 1
fi

# Use current directory name if no project name is given
if [ $PROJ_NAME = "." ]; then
    PROJ_NAME=${PWD##*/}
else
    mkdir $PROJ_NAME
    cd $PROJ_NAME
fi

###########################
# Solution setup
###########################

# Create a new solution
dotnet new sln -n $PROJ_NAME 

echo -e "${GREEN}Solution $PROJ_NAME.sln created.${ENDCOLOR}"

###########################
# Webapi setup
###########################

dotnet new webapi -n $PROJ_NAME.Webapi
dotnet sln add $PROJ_NAME.Webapi

echo -e "${GREEN}Webapi $PROJ_NAME.Webapi created.${ENDCOLOR}"

###########################
# Angular setup
###########################

dotnet new angular -n $PROJ_NAME.Web
dotnet sln add $PROJ_NAME.Web

echo -e "${GREEN}Angular frontend $PROJ_NAME.Web created.${ENDCOLOR}"

###########################
# Service setup
###########################

dotnet new classlib -n $PROJ_NAME.Service
dotnet sln add $PROJ_NAME.Service

echo -e "${GREEN}Service $PROJ_NAME.Service created.${ENDCOLOR}"

###########################
# EF Core setup
###########################

# Cross platform entity models
dotnet new classlib -n $PROJ_NAME.EntityModels.SqlServer
dotnet new classlib -n $PROJ_NAME.EntityModels.Sqlite

# Cross platform data context
dotnet new classlib -n $PROJ_NAME.DataContext.SqlServer
dotnet new classlib -n $PROJ_NAME.DataContext.Sqlite

dotnet sln add $PROJ_NAME.EntityModels.SqlServer
dotnet sln add $PROJ_NAME.EntityModels.Sqlite

echo -e "${GREEN}Finished setting up EF Core projects.${ENDCOLOR}"

###########################
# Unit tests
###########################

dotnet new nunit -n $PROJ_NAME.UnitTests
dotnet sln add $PROJ_NAME.UnitTests

echo -e "${GREEN}Finished creating unit test project.${ENDCOLOR}"

###########################
# Link projects
###########################

# Link EntityModels to DataContext...
dotnet add $PROJ_NAME.DataContext.SqlServer reference $PROJ_NAME.EntityModels.SqlServer
dotnet add $PROJ_NAME.DataContext.Sqlite reference $PROJ_NAME.EntityModels.Sqlite

# ...the DataContext to the Service...
dotnet add $PROJ_NAME.Service reference $PROJ_NAME.DataContext.SqlServer
dotnet add $PROJ_NAME.Service reference $PROJ_NAME.DataContext.Sqlite

# ...and the Service & DataContext to the Webapi
dotnet add $PROJ_NAME.Webapi reference $PROJ_NAME.Service
dotnet add $PROJ_NAME.Webapi reference $PROJ_NAME.DataContext.SqlServer
dotnet add $PROJ_NAME.Webapi reference $PROJ_NAME.DataContext.Sqlite

# Link the service and data context projects to the unit tests
dotnet add $PROJ_NAME.UnitTests reference $PROJ_NAME.Service
dotnet add $PROJ_NAME.UnitTests reference $PROJ_NAME.DataContext.SqlServer
dotnet add $PROJ_NAME.UnitTests reference $PROJ_NAME.DataContext.Sqlite

echo -e "${GREEN}Finished linking projects.${ENDCOLOR}"

###########################
# Comment out unused EF Core
###########################

SQLITE_DEPENDENCY="<ProjectReference Include=\"..\\$PROJ_NAME.DataContext.Sqlite\\$PROJ_NAME.DataContext.Sqlite.csproj\" />"
SQLSERVER_DEPENDENCY="<ProjectReference Include=\"..\\$PROJ_NAME.DataContext.SqlServer\\$PROJ_NAME.DataContext.SqlServer.csproj\" />"
PROJECTS=("$PROJ_NAME.Service" "$PROJ_NAME.Webapi" "$PROJ_NAME.UnitTests")

if [ "$DB_PROVIDER" = "mssql" ]; then
    for PROJECT in "${PROJECTS[@]}"
    do
        echo "${YELLOW}Commenting out SQLite dependency in $PROJECT.csproj${ENDCOLOR}"
        sed -i '' "s~$(printf '%s\n' "$SQLITE_DEPENDENCY" | sed -e 's/[\/&]/\\&/g')~<!-- ${SQLITE_DEPENDENCY//\\/\\\\} -->~" "$PROJECT/$PROJECT.csproj"
    done
fi

if [ "$DB_PROVIDER" = "sqlite" ]; then
    for PROJECT in "${PROJECTS[@]}"
    do
        echo "${YELLOW}Commenting out SQL Server dependency in $PROJECT.csproj${ENDCOLOR}"
        sed -i '' "s~$(printf '%s\n' "$SQLSERVER_DEPENDENCY" | sed -e 's/[\/&]/\\&/g')~<!-- ${SQLSERVER_DEPENDENCY//\\/\\\\} -->~" "$PROJECT/$PROJECT.csproj"
    done
fi

echo "${GREEN}Commented out unused EF Core dependency.${ENDCOLOR}"

###########################
# Install packages
###########################

# DataContext
dotnet add $PROJ_NAME.DataContext.SqlServer package Microsoft.EntityFrameworkCore.SqlServer --version 8.0.0
dotnet add $PROJ_NAME.DataContext.Sqlite package Microsoft.EntityFrameworkCore.Sqlite --version 8.0.0

# Service
dotnet add $PROJ_NAME.Service package Microsoft.EntityFrameworkCore --version 8.0.0
dotnet add $PROJ_NAME.Service package Microsoft.Extensions.Hosting.Abstractions --version 8.0.0

# Webapi
dotnet add $PROJ_NAME.Webapi package Swashbuckle.AspNetCore --version 6.5.0

echo -e "${GREEN}Finished installing packages.${ENDCOLOR}"

###########################
# Cleanup
###########################

# Build solution
dotnet build

# Open solution in VS Code
code .
