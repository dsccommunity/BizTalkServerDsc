function Copy-Object {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)]
        $Original
    )

    $deepClone = $null

    if($null -ne $Original) {
        $memStream = New-Object IO.MemoryStream
        $formatter = New-Object Runtime.Serialization.Formatters.Binary.BinaryFormatter
        $formatter.Serialize($memStream, $Original)
        $memStream.Position = 0
        $deepClone = $formatter.Deserialize($memStream)
        $memStream.Close()
    }

    return $deepClone
}

<#
    .NOTES
        There is no PowerShell function to make a deep copy.
        Clone() function for hashtables does only a shallow copy.
        Reference has to be used here to handle null or empty objects.
 
    .DESCRIPTION
        This function writes a deep copy of an input object
        to a reference passed.
        If original object is null, then null will be returned.
        Otherwise object is copied via memory stream.
 
    .PARAMETER Original
        It is an object that will be copied.
        It can be null.
     
    .EXAMPLE
        $clone = Copy-Object -Original $original
#>
