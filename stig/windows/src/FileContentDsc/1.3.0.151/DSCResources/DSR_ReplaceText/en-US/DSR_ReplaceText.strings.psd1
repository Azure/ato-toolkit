# Localized resources for DSR_ReplaceText

ConvertFrom-StringData @'
    SearchForTextMessage = Searching using RegEx '{1}' in file '{0}'.
    StringNotFoundMessageAppend = String not found using RegEx '{1}' in file '{0}', change required.
    StringNotFoundMessage = String not found using RegEx '{1}' in file '{0}', change not required.
    StringMatchFoundMessage = String(s) '{2}' found using RegEx '{1}' in file '{0}'.
    StringReplacementRequiredMessage = String found using RegEx '{1}' in file '{0}', replacement required.
    StringNoReplacementMessage = String found using RegEx '{1}' in file '{0}', no replacement required.
    StringReplaceTextMessage = String replaced by '{1}' in file '{0}'.
    StringReplaceSecretMessage = String replaced by secret text in file '{0}'.
    FileParentNotFoundError = File parent path '{0}' not found.
    FileEncodingNotInDesiredState = File encoding is set to '{0}' but should be set to '{1}', Change required.
'@
