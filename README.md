This script generates a binary Bit Vector for an input hexadecimal string and then Enables/Disables a specific Bit position in the string. 
This script is used to when the existing 64 bit positions are exhausted for current features and new features need to be added. This can support byte aligned & non byte aligned data of 'N' bits since we cannot do bit mask operations on data > 64 bits.


The command line to execute the script is as follows.

[root@kodiakdb BitVectorGeneration]# perl SetUnsetFeatureBitVector.pl


ENTER INPUT BYTE ALIGNED/NON BYTE ALIGNED HEX STRING
98452FAC455DA88888188899991000000000FDAAAAFF45555555555555557885FC


ENTER OPTION Enable/Disable
enable


ENTER BIT POSITION for Enable/Disable
154
INPUT HEX STRING:                       98452FAC455DA88888188899991000000000FDAAAAFF45555555555555557885FC


BIT ENABLED HEX STRING:                 98452fac455da88888188899991400000000fdaaaaff45555555555555557885fc AT BIT POSITION: 154

