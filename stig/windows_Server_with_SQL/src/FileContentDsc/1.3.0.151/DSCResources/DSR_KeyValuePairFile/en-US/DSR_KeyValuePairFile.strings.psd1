# Localized resources for DSR_ReplaceText

ConvertFrom-StringData @'
    SearchForKeyMessage = Searching for key '{1}' in file '{0}'.
    KeyNotFoundMessage = Key '{1}' not found in file '{0}'.
    KeyFoundMessage = Key '{1}' found in file '{0}' with the value(s) '{2}'.
    KeyRemoveMessage = Key '{1}' found in file '{0}' but has been removed.
    KeyAddMessage = Key '{1}' not found in file '{0}' so has been added.
    KeyUpdateMessage = Key '{1}' found in file '{0}' and has been updated.
    KeyNotFoundButShouldExistMessage = Key '{1}' not found in file '{0}' but should exist. Change required.
    KeyNotFoundAndShouldNotExistMessage = Key '{1}' not found in file '{0}' and should not exist. Change not required.
    KeyFoundButNoReplacementMessage = Key '{1}' found in file '{0}' and should exist and value(s) are correct. Change not required.
    KeyFoundButShouldNotExistMessage = Key '{1}' found in file '{0}' but should not exist. Change required.
    KeyValuePairFileNotFound = Key Value Pair file '{0}' not found.
    KeyValuePairFileIsEmpty = Key Value Pair file '{0}' is empty.
    FileParentNotFoundError = File parent path '{0}' not found.
    FileEncodingNotInDesiredState = File encoding is set to '{0}' but should be set to '{1}', Change required.
'@
