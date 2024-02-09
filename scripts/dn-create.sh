#!/bin/zsh

###########################
# This script creates a new
# .NET fullstack project
# with my typical setup.
# WebApi, Anuglar, EF Core
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
# WebApi setup
###########################

dotnet new WebApi -n $PROJ_NAME.WebApi
dotnet sln add $PROJ_NAME.WebApi

echo -e "${GREEN}WebApi $PROJ_NAME.WebApi created.${ENDCOLOR}"

###########################
# Angular setup
###########################

dotnet new angular -n $PROJ_NAME.Web
dotnet sln add $PROJ_NAME.Web

echo -e "${GREEN}Angular frontend $PROJ_NAME.Web created.${ENDCOLOR}"

###########################
# Services setup
###########################

dotnet new classlib -n $PROJ_NAME.Services
dotnet sln add $PROJ_NAME.Services

echo -e "${GREEN}Services $PROJ_NAME.Services created.${ENDCOLOR}"

###########################
# EF Core setup
###########################

# Cross platform entity models
dotnet new classlib -n $PROJ_NAME.Common.EntityModels.SqlServer
dotnet new classlib -n $PROJ_NAME.Common.EntityModels.Sqlite

# Cross platform data context
dotnet new classlib -n $PROJ_NAME.Common.DataContext.SqlServer
dotnet new classlib -n $PROJ_NAME.Common.DataContext.Sqlite

dotnet sln add $PROJ_NAME.Common.EntityModels.SqlServer
dotnet sln add $PROJ_NAME.Common.EntityModels.Sqlite

dotnet sln add $PROJ_NAME.Common.DataContext.SqlServer
dotnet sln add $PROJ_NAME.Common.DataContext.Sqlite

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
dotnet add $PROJ_NAME.Common.DataContext.SqlServer reference $PROJ_NAME.Common.EntityModels.SqlServer
dotnet add $PROJ_NAME.Common.DataContext.Sqlite reference $PROJ_NAME.Common.EntityModels.Sqlite

# ...the DataContext to the Services...
dotnet add $PROJ_NAME.Services reference $PROJ_NAME.Common.DataContext.SqlServer
dotnet add $PROJ_NAME.Services reference $PROJ_NAME.Common.DataContext.Sqlite

# ...and the Services & DataContext to the WebApi
dotnet add $PROJ_NAME.WebApi reference $PROJ_NAME.Services
dotnet add $PROJ_NAME.WebApi reference $PROJ_NAME.Common.DataContext.SqlServer
dotnet add $PROJ_NAME.WebApi reference $PROJ_NAME.Common.DataContext.Sqlite

# Link the Services and data context projects to the unit tests
dotnet add $PROJ_NAME.UnitTests reference $PROJ_NAME.Services
dotnet add $PROJ_NAME.UnitTests reference $PROJ_NAME.Common.DataContext.SqlServer
dotnet add $PROJ_NAME.UnitTests reference $PROJ_NAME.Common.DataContext.Sqlite

echo -e "${GREEN}Finished linking projects.${ENDCOLOR}"

###########################
# Comment out unused EF Core
###########################

SQLITE_DEPENDENCY="<ProjectReference Include=\"..\\$PROJ_NAME.Common.DataContext.Sqlite\\$PROJ_NAME.Common.DataContext.Sqlite.csproj\" />"
SQLSERVER_DEPENDENCY="<ProjectReference Include=\"..\\$PROJ_NAME.Common.DataContext.SqlServer\\$PROJ_NAME.Common.DataContext.SqlServer.csproj\" />"
PROJECTS=("$PROJ_NAME.Services" "$PROJ_NAME.WebApi" "$PROJ_NAME.UnitTests")

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
dotnet add $PROJ_NAME.Common.DataContext.SqlServer package Microsoft.EntityFrameworkCore.SqlServer --version 8.0.0
dotnet add $PROJ_NAME.Common.DataContext.Sqlite package Microsoft.EntityFrameworkCore.Sqlite --version 8.0.0

# Services
dotnet add $PROJ_NAME.Services package Microsoft.EntityFrameworkCore --version 8.0.0
dotnet add $PROJ_NAME.Services package Microsoft.Extensions.Hosting.Abstractions --version 8.0.0

# WebApi
dotnet add $PROJ_NAME.WebApi package Swashbuckle.AspNetCore --version 6.5.0

echo -e "${GREEN}Finished installing packages.${ENDCOLOR}"

###########################
# Build and cleanup
###########################

# Add a README.md
echo "# $PROJ_NAME" > README.md
echo "This project was bootstrapped with the dnc script." >> README.md
echo "The configured database provider is $DB_PROVIDER." >> README.md

# Build solution
dotnet build

# Open solution in VS Code
code .
