package FeatureBitVector;

use Data::Dumper;
use Term::ANSIColor;
require Exporter;
@ISA = ('Exporter');
@EXPORT = qw/IsEnabled IsDisabled FsEnable FsDisable GetEpochTime/;



sub GenerateBitVectors
{
        my ($FsHexInputString)=@_;
        my @FsHexReverseInputArray=reverse(split(//,unpack ("H".length($FsHexInputString),pack("H*",$FsHexInputString))));
        my @FsHexInputArray=split(//,unpack ("H".length($FsHexInputString),pack("H*",$FsHexInputString)));
        my $vector='';
        my $idx=0;
        foreach (@FsHexReverseInputArray)
        {
            vec($vector, $idx, 4) = hex($_);  # set bit
            $idx+=1;
        }
        my $HexReverseVector=$vector;
        $idx=0;
        $vector='';
        foreach (@FsHexInputArray)
        {
            vec($vector, $idx, 4) = hex($_);  # set bit
            $idx+=1;
        }
        my $HexVector=$vector;
        return ($HexVector,$HexReverseVector);

}

sub IsBitVectorEnable
{
        my ($self, $FsHexInputString, $BitPosition) = @_;
        my $IsBitVecEnabled=1;

        $FsHexInputString='00' if $FsHexInputString eq '0';
        my ($BitVector,$ReverseBitVector)=GenerateBitVectors($FsHexInputString);

        if (vec($ReverseBitVector,$BitPosition,1))
        {
            PrintLog($self, "BIT POSITION:$BitPosition IS ALREADY SET FOR INPUT HEX STRING: $FsHexInputString");
            $IsBitVecEnabled=0;
        }
        return $IsBitVecEnabled;
}

sub IsBitVectorDisable
{
        my ($self, $FsHexInputString, $BitPosition) = @_;
        my $IsBitVecDisabled=1;

        $FsHexInputString='00' if $FsHexInputString eq '0';
        my ($BitVector,$ReverseBitVector)=GenerateBitVectors($FsHexInputString);

        if (!(vec($ReverseBitVector,$BitPosition,1)))
        {
            PrintLog($self, "BIT POSITION:$BitPosition IS ALREADY UNSET FOR INPUT HEX STRING: $FsHexInputString");
            $IsBitVecDisabled=0;
        }
        return $IsBitVecDisabled;
}

sub FsBitVectorEnable
{
        my ($self, $FsHexInputString, $BitPosition) = @_;
        my ($FinalHexString,$AppendZeroBytes);
        my $idx=1;
        my $EnableStatus=1;

        #### To handle zero appending logic in case $BitPosition > (length($FsHexInputString)*4)-1 ###########
        $FsHexInputString='00' if $FsHexInputString eq '0';
        if ($BitPosition > (length($FsHexInputString)*4)-1)
        {
            while($FsHexInputString)
            {
                last if ((($BitPosition - ((length($FsHexInputString)*4)-1) + $idx)%4) == 0);
                $idx+=1;
            }
            $AppendZeroBytes='0' x ((($BitPosition - ((length($FsHexInputString)*4)-1))+$idx)/4);
            $FsHexInputString=$AppendZeroBytes.$FsHexInputString;
            PrintLog($self, "INPUT HEX STRING AFTER ZERO APPEND:                        $FsHexInputString");
        }
        if($FsHexInputString eq '' || $BitPosition eq '')
        {
            PrintLog($self, "Null values passed to FsBitVectorEnable() function!!", 'error');
            $EnableStatus = 2;
        }
        my ($BitVector,$ReverseBitVector)=GenerateBitVectors($FsHexInputString);
        if (vec($ReverseBitVector,$BitPosition,1))
        {
            #PrintLog($self, "BIT POSITION:$BitPosition IS ALREADY SET FOR INPUT HEX STRING: $FsHexInputString");
            $EnableStatus=0;
        }
        vec($ReverseBitVector,$BitPosition,1) = 1;
        $FinalHexString=reverse(unpack("h".length($FsHexInputString),$ReverseBitVector));
        $FinalHexString='0'.$FinalHexString if (length($FinalHexString)%2); ### Condition to take care odd nibble count before pack
        PrintLog($self, "BIT ENABLED HEX STRING:                  $FinalHexString AT BIT POSITION: $BitPosition");
        return ($FinalHexString,$EnableStatus);
}

sub FsBitVectorDisable
{

        my ($self,$FsHexInputString, $BitPosition) = @_;
        my ($FinalHexString,$AppendZeroBytes);
        my $idx=1;
        my $DisableStatus=1;

        #### To handle zero appending logic in case $BitPosition > (length($FsHexInputString)*4)-1 ###########
        $FsHexInputString='00' if $FsHexInputString eq '0';
        if ($BitPosition > (length($FsHexInputString)*4)-1)
        {
            while($FsHexInputString)
            {
                last if ((($BitPosition - ((length($FsHexInputString)*4)-1) + $idx)%4) == 0);
                $idx+=1;
            }
            $AppendZeroBytes='0' x ((($BitPosition - ((length($FsHexInputString)*4)-1))+$idx)/4);
            $FsHexInputString=$AppendZeroBytes.$FsHexInputString;
            PrintLog($self,"INPUT HEX STRING AFTER ZERO APPEND:                        $FsHexInputString");
        }
        if($FsHexInputString eq '' || $BitPosition eq '')
        {
            PrintLog($self, "Null values passed to FsBitVectorEnable() function!!", 'error');
            $DisableStatus = 2;
            return ($FinalHexString,$DisableStatus);
        }
        my ($BitVector,$ReverseBitVector)=GenerateBitVectors($FsHexInputString);
        if (!(vec($ReverseBitVector,$BitPosition,1)))
        {
            #PrintLog($self, "BIT POSITION:$BitPosition IS ALREADY UNSET FOR INPUT HEX STRING: $FsHexInputString");
            $DisableStatus=0;
        }
        vec($ReverseBitVector,$BitPosition,1) = 0;
        $FinalHexString=reverse(unpack("h".length($FsHexInputString),$ReverseBitVector));
        $FinalHexString='0'.$FinalHexString if (length($FinalHexString)%2); ### Condition to take care odd nibble count before pack
        PrintLog($self, "BIT DISABLED HEX STRING:                 $FinalHexString AT BIT POSITION: $BitPosition");
        return ($FinalHexString,$DisableStatus);
}

sub GetDecimalFS1Value
{
    my ($self,$FsHexInputString) = @_;
    my $Mask='7FFFFFFFFFFFFFFF'; ### To get 0-62 Bits from input Hex

    $FsHexInputString='0x'.$FsHexInputString;
    $Mask='0x'.$Mask;
    my $HexAnded = Math::BigInt->new($Mask) & $FsHexInputString;
    my $DecOutFS1=sprintf("%d", hex($HexAnded->as_hex()));
    return $DecOutFS1;
}

1;
