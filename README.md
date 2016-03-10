# Helion Code Engine : Schema V2
This is a temporary repo for discussion of the V2 version of the Helion CodeEngine database and REST API schema.

## Database
Load the associated [code_engine.sql](code_engine.sql) file into MySQL, or view the visualization diagram below:
![Database schema](codeengine-schema.png "Database schema")



## Notes & issues

* Post-deploy actions: No promises made about the accuracy of this section of the API or DB schema. Need to consult with team.

* `user_vcs_credential`: this is a join table for a user's VCS credentials (e.g. a GitHub OAuth2 token). Do we (as CREST) actually need this, or is this sort of thing best managed by the client (web or CLI)?

* `project_invite`: We should really be generating unique per-user invitations.
