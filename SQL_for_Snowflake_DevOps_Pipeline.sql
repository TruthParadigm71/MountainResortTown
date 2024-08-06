-- ***************************************************************************************
-- Create the building blocks of  DevOps pipeline.
-- ***************************************************************************************

-- Create a secret object to store GitHub credentials.
CREATE OR REPLACE SECRET GITHUB_SECRET
TYPE = PASSWORD 
USERNAME = 'TruthParadigm71'
PASSWORD = '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'
;

SHOW SECRETS 
;

DESCRIBE SECRET GITHUB_SECRET 
;

-- Create a Git API integration.
CREATE OR REPLACE API INTEGRATION GITHUB_INTEGRATION
    API_PROVIDER = GIT_HTTPS_API 
    API_ALLOWED_PREFIXES = ('https://github.com/TruthParadigm71')
    ALLOWED_AUTHENTICATION_SECRETS = (GITHUB_SECRET)
    ENABLED = TRUE 
    ;

SHOW INTEGRATIONS
;

SHOW API INTEGRATIONS
;

-- Create a Git Repository
CREATE OR REPLACE GIT REPOSITORY GIT_REPO_DEMO
    API_INTEGRATION = GITHUB_INTEGRATION 
    GIT_CREDENTIALS = GITHUB_SECRET 
    ORIGIN = 'https://github.com/TruthParadigm71/MountainResortTown.git'
    ;

SHOW GIT REPOSITORIES
;

DESCRIBE GIT REPOSITORY GIT_REPO_DEMO 
;

-- We can now browse the repository. Create a role to do that.
LIST @GIT_REPO_DEMO/branches/main 
;

SHOW GIT TAGS IN GIT_REPO_DEMO
;

ALTER GIT REPOSITORY GIT_REPO_DEMO FETCH
;

-- Execute Immediate
EXECUTE IMMEDIATE FROM @GIT_REPO_DEMO/branches/main/SQL_for_Snowflake_Execute_Immediate.sql 
;