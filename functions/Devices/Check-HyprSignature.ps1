function Check-HyprSignature {
  param(
    [Parameter(Mandatory)][string]$Username,
    [Parameter(Mandatory)][string]$KeyId,
    [Parameter(Mandatory)][string]$SignatureData,
    [Parameter(Mandatory)][PSCustomObject]$Config
  )
  
  $body = @{
    username = $Username
    keyId = $KeyId
    signatureData = $SignatureData
    rpAppId = $Config.RPAppId
  }
  
  try {
    $response = Invoke-HyprApi -Method POST -Endpoint "/rp/api/versioned/fido2/signature/validate" -Config $Config -Body $body -TokenType RP
    
    return [PSCustomObject]@{
      Username = $Username
      KeyId = $KeyId
      IsValid = $response.valid
      ValidationTimestamp = Get-Date
    }
  }
  catch {
    throw "Failed to validate signature: $($_.Exception.Message)"
  }
}
