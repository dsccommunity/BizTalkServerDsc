# NOTE: This is a stream token configuration file, all changes made should be done to all stream token configuration files

@{
    Secrets = @{ # TODO: Use BitWarden instead to retreive secrets
        '<DOMAIN>\<ACCOUNT>' = '<PASSWORD>' 
        '<DOMAIN>\<ISOLATED ACCOUNT>' = '<PASSWORD>'
        '<DOMAIN>\<IN PROCESS ACCOUNT>' = '<PASSWORD>'
        'SSO_ID_BACKUP_SECRET_REMINDER' = '<REMINDER>'
    }
    Tokens = @{
        SSO_ID_BACKUP_SECRET_FILE = 'C:\Temp\BizTalk SSO Backup secret file.xml'
        SSO_ID_BACKUP_SECRET_PASSWORD = '{{<DOMAIN>\<IN PROCESS ACCOUNT>}}'
        SSO_ID_BACKUP_SECRET_REMINDER = '{{SSO_ID_BACKUP_SECRET_REMINDER}}'

        BTS_GROUP_DOMAIN = '<DOMAIN>'
        BTS_DB_ID_DOMAIN = '<DOMAIN>'
        BTS_ACCOUNT_DOMAIN = '<DOMAIN>'

        SSO_ADMIN_GROUP = 'SSO Administrators'
        SSO_AFFILIATE_ADMIN_GROUP = 'SSO Affiliate Administrators'

        ENTSSO_ACCOUNT = '<IN PROCESS ACCOUNT>'
        ENTSSO_PASSWORD = '{{<DOMAIN>\<IN PROCESS ACCOUNT>}}'

        SSO_DB_ID_ACCOUNT = '<IN PROCESS ACCOUNT>'
        SSO_DB_ID_SERVER = 'localhost'
        SSO_DB_ID_DATABASE = 'SSODB'
        SSO_DB_ID_PASSWORD = '{{<DOMAIN>\<IN PROCESS ACCOUNT>}}'

        WMI_DB_ID_ACCOUNT = '<IN PROCESS ACCOUNT>'
        WMI_DB_ID_SERVER = 'localhost'
        WMI_DB_ID_DATABASE = 'BizTalkMgmtDb'
        WMI_DB_ID_PASSWORD = '{{<DOMAIN>\<IN PROCESS ACCOUNT>}}'

        BTS_DB_ID_ACCOUNT = '<IN PROCESS ACCOUNT>'
        BTS_DB_ID_SERVER = 'localhost'
        BTS_DB_ID_DATABASE = 'BizTalkMsgBoxDb'
        BTS_DB_ID_PASSWORD = '{{<DOMAIN>\<IN PROCESS ACCOUNT>}}'

        BTS_BRE_DB_ID_ACCOUNT = 'BtsRuleEngine'
        BTS_BRE_DB_ID_SERVER = 'localhost'
        BTS_BRE_DB_ID_DATABASE = 'BizTalkRuleEngineDb'
        BTS_BRE_DB_ID_PASSWORD = '{{<DOMAIN>\<IN PROCESS ACCOUNT>}}'

        BTS_TD_DB_ID_ACCOUNT = '<IN PROCESS ACCOUNT>'
        BTS_TD_DB_ID_SERVER = 'localhost'
        BTS_TD_DB_ID_DATABASE = 'BizTalkDTADb'
        BTS_TD_DB_ID_PASSWORD = '{{<DOMAIN>\<IN PROCESS ACCOUNT>}}'
        
        BTS_ADMIN_GROUP =  'BizTalk Administrators Group'
        BTS_OPERATOR_GROUP = 'BizTalk Operators Group'
        BTS_B2B_OPERATOR_GROUP = 'BizTalk B2B Operators Group' 
        BTS_READONLY_USER_GROUP = 'BizTalk Read Only Users Group' 

        BTS_HOST_GROUP = 'BizTalk Application Users'
        BTS_HOST_ACCOUNT = '<IN PROCESS ACCOUNT>'
        BTS_HOST_PASSWORD = '{{<DOMAIN>\<IN PROCESS ACCOUNT>}}'

        BTS_ISO_HOST_GROUP = 'BizTalk Isolated Host Users'
        BTS_ISO_HOST_ACCOUNT = '<ISOLATED ACCOUNT>'
        BTS_ISO_HOST_PASSWORD = '{{<DOMAIN>\<ISOLATED ACCOUNT>}}'

        BTS_RESTAPI_ACCOUNT = '<IN PROCESS ACCOUNT>'
        BTS_RESTAPI_PASSWORD = '{{<DOMAIN>\<IN PROCESS ACCOUNT>}}'

        BTS_ODS_DOMAIN = '<DOMAIN>' 
        BTS_ODS_ACCOUNT = '<IN PROCESS ACCOUNT>'
        BTS_ODS_PASSWORD = '{{<DOMAIN>\<IN PROCESS ACCOUNT>}}'

        BTS_TMS_DOMAIN = '<DOMAIN>' 
        BTS_TMS_ACCOUNT = '<IN PROCESS ACCOUNT>'
        BTS_TMS_PASSWORD = '{{<DOMAIN>\<IN PROCESS ACCOUNT>}}'
    }
}