@{
    All = @(
        @{ SetupCredentials = @{ Type = 'Account'; Domain = '*******'; UserName = 'TBD'; Password = 'TBD' } } 
    )
    BizTalk = @(
        @{ SSO_ID_BACKUP_SECRET_FILE = @{ Type = 'File'; File = 'C:\Temp\BizTalk SSO Backup secret file.xml' } }
        @{ SSO_ID_BACKUP_SECRET_PASSWORD = @{ Type = 'Password'; Password = 'TBD' } } 
        @{ SSO_ID_BACKUP_SECRET_REMINDER = @{ Type = 'Reminder'; Reminder = 'TBD' } } 
        @{ ENTSSO = @{ Type = 'Account'; Domain = '*******'; UserName = 'TBD'; Password = 'TBD' } } 
        @{ SSO_DB_ID = @{ Type = 'DBConnectionString'; Domain = '*******'; UserName = 'TBD'; Password = 'TBD'; Server = 'TBD'; Database = 'TBD' } } 
        @{ WMI = @{ Type = 'DBConnectionString'; Domain = '*******'; UserName = 'TBD'; Password = 'TBD'; Server = 'TBD'; Database = 'TBD' } } 
        @{ CREATEORJOIN = @{ Type = 'DBConnectionString'; Domain = '*******'; UserName = 'TBD'; Password = 'TBD'; Server = 'TBD'; Database = 'TBD' } } 
        @{ BTS_TD = @{ Type = 'DBConnectionString'; Domain = '*******'; UserName = 'TBD'; Password = 'TBD'; Server = 'TBD'; Database = 'TBD' } } 
        @{ BTS_ADMIN_GROUP = @{ Type = 'Group'; Domain = '*******'; Group = 'TBD' } } 
        @{ BTS_OPERATOR_GROUP = @{ Type = 'Group'; Domain = '*******'; Group = 'TBD' } } 
        @{ BTS_B2B_OPERATOR_GROUP = @{ Type = 'Group'; Domain = '*******'; Group = 'TBD' } } 
        @{ BTS_READONLY_USER_GROUP = @{ Type = 'Group'; Domain = '*******'; Group = 'TBD' } } 
        @{ BTS_HOST_GROUP = @{ Type = 'Group'; Domain = '*******'; Group = 'TBD' } } 
        @{ BTS_ISO_HOST = @{ Type = 'Account'; Domain = '*******'; UserName = 'TBD'; Password = 'TBD' } } 
    )
    ServiceFabric = @()
    SqlServer = @()
}