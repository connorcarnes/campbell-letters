﻿# URL was built by going to https://scholarship.rice.edu/handle/1911/21706/browse
# And inspecting the network tab of browser developer tools
$Url = 'https://scholarship.rice.edu/handle/1911/21706/browse?resetOffset=true&type=dateissued&sort_by=2&order=ASC&rpp=99&update='

$Request = Invoke-WebRequest -Uri $Url
$filter  = 'type=|class=|role=|79050|12341|21706'
$Links   = $Request.links |
    Where-Object {$_.OuterHTML -match 'handle' -and $_.OuterHTML -notmatch $filter}

$Output = [System.Collections.ArrayList]::new()
foreach ($Link in $Links) {
    Write-Host $Link.OuterHTML -foregroundcolor cyan
    $Temp = [PSCustomObject]@{
        'Title'   = $link.OuterHTML
        'Content' = $null
    }

    $base         = 'https://scholarship.rice.edu'
    $FirstRequest = Invoke-WebRequest -Uri ($base + $link.href)

    $TextLink = $FirstRequest.links
        | Where-Object {$_.outerHTML -match 'txt' -and $_.outerHTML -notmatch 'image-link'}

    $TextContent  = (Invoke-WebRequest -Uri ($base + $TextLink.href)).content
    $Temp.Content = $TextContent

    $null = $Output.Add($Temp)
}

# Copy and paste $Page into readme
$Page = @"
# campbell-letters

Correspondence related to John Campbell and family. Campbell immigrated from Ireland to Texas ca. 1820 and encouraged his family to join him.

This page is simply the text documents from https://scholarship.rice.edu/handle/1911/21706 compiled into a single chronological page.

"@

foreach ($letter in $Output) {
    $Page += @"
## $($letter.Title)

``````
$($letter.Content)
``````

"@
}