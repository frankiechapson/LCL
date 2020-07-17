# Login Controll for Oracle

## Oracle SQL and PL/SQL solution to controll logins

## Why?
I have two reasons:

1. to refuse the unauthorized logins, and
2. log the attempts


## How?

There is a logon trigger which checks the
 * Oracle user
 * OS user
 * IP address of the client
 * Program / Application

If the login allowed then goes on, but if it did not, then logs the data and raise an error.

For DBA roled users the login is allowed all the time despite the trigger is invalid nor raises an error.

There is a table to controll the logins:
```sql
  ORACLE_USER             VARCHAR2 (   400 )
  OS_USER                 VARCHAR2 (   400 )
  IP_ADDRESS              VARCHAR2 (   400 )
  PROGRAM                 VARCHAR2 (   400 )
  ENABLED                 CHAR     (     1 )     Y or N
```
This table contains the valid user/client/program combinations.<br>
The column values will use with LIKE, so it can be pattern.
i.e. "%" means "every" user/IP address/program e.t.c.
But '%','%','%','%','Y' means anybody from anywhere, and this overwrites any other rules!
The refused logon data will be logged into LCL_LOG table.<br>
There is an ENABLED column in the LCL_TABLE too, so you can disabled the logins anytime to set this value to "N".


The whole solution is not too complicated, so see the install script file for more details!

