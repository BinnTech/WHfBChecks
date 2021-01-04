function Get-WHFBCertTemplate {
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)]
        [string]
        $CertPath,
        [Parameter()]
        [string]
        $Computername,
        [Parameter(Mandatory = $false)]
        [pscredential]
        $Creds
    )
    if ($PSBoundParameters.ContainsKey('Creds')) {
        $cred = $creds
    }
    else {
        if ($PSBoundParameters.ContainsKey('Computername')) {
            $cred = Get-Credential
        }
    }
    try {
        $res = $null
        if ($PSBoundParameters.ContainsKey('Computername')) {
            $res = Invoke-Command -ComputerName $Computername -ScriptBlock {
                $cert = Get-ChildItem $CertPath
                $templateExt = $cert.Extensions | Where-Object { $_.Oid.FriendlyName -match 'Certificate Template Information' }
                $decoded = ($templateExt.Format(1) -split "`n") | Where-Object {$_ -like '*=*'}
                $temp = New-Object psobject
                foreach($d in $decoded) {
                    $TemplateSplit = $d -split '='
                    $temp | Add-Member -Name $TemplateSplit[0] -MemberType NoteProperty -Value $TemplateSplit[1]
                }
                $temp} -Credential $cred
        }
        else {
             $cert = Get-ChildItem $CertPath
                $templateExt = $cert.Extensions | Where-Object { $_.Oid.FriendlyName -match 'Certificate Template Information' }
                $decoded = ($templateExt.Format(1) -split "`n") | Where-Object {$_ -like '*=*'}
                $res = New-Object psobject
                foreach($d in $decoded) {
                    $TemplateSplit = $d -split '='
                    $temp | Add-Member -Name $TemplateSplit[0] -MemberType NoteProperty -Value $TemplateSplit[1]
                }
        }
        return $res
    }
    catch {
        Write-Warning $_.Exception.Message
    }
}