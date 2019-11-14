NewCommitment(){
	PowerShellCommand = powershell -noprofile -Command Import-Module Outlook; Get-NewCommitment
	;Msgbox, PS: %PowerShellCommand%
	Run %PowerShellCommand%,,, psPid
	Return
}

ProcessFolderCategories(){
	PowerShellCommand = powershell -Command "import-module C:\Users\jroberts\Documents\WindowsPowerShell\Modules\Outlook\Outlook.psd1; Invoke-ProcessFolderCategories -Mailbox 'jim.roberts@farmcreditbank.com' -ProcessFolderList ('Inbox', 'Sent Items', 'Inbox\Archive') -TargetRootFolderPath 'Inbox'"
	;Msgbox, PS: %PowerShellCommand%
	Run %PowerShellCommand%,,, psPid
	Return
}