# Global in Library
#use strict;
#use warnings;
use Data::Dumper;

sub GenerateBitVectors
{
        my $FsHexInputString=shift;
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

sub ValidateBitSetUnset
{
        my $FsHexInputString=shift;
        my $ReverseBitVector=shift;
        my $BitPosition=shift;
        my $BitOperation=shift;
        my $Status=0;
        if (($BitOperation eq 'Enable') and (vec($ReverseBitVector,$BitPosition,1)))
        {
                        print "BIT POSITION:'$BitPosition' IS ALREADY SET FOR INPUT HEX STRING: $FsHexInputString\n";
                        $Status=1;
        }
        elsif(($BitOperation eq 'Disable') and !(vec($ReverseBitVector,$BitPosition,1)))
        {
                        print "BIT POSITION:'$BitPosition' IS ALREADY UNSET FOR INPUT HEX STRING: $FsHexInputString\n";
                        $Status=1;
        }
        return $Status;
}


sub FsEnableBitVector
{
        #my ($self, $FsHexInputString, $BitPosition) = @_;
        my ($FsHexInputString, $BitPosition) = @_;
        my ($NibbleMaskPattern,$Nibble,$NibblePosn,$FinalHexString);

        if (($BitPosition eq '') or ($BitPosition > (length($FsHexInputString)*4)-1))
        {
                my $Hexinputlength=(length($FsHexInputString)*4)-1;
                print "BIT POSITION SHOULD BE A POSITIVE INTEGER & BETWEEN 0 - $Hexinputlength\n";
                exit(0);
        }

        print "INPUT HEX STRING:                        $FsHexInputString \n";
        my ($BitVector,$ReverseBitVector)=GenerateBitVectors($FsHexInputString);
        my $BitSetStatus=ValidateBitSetUnset($FsHexInputString,$ReverseBitVector,$BitPosition,'Enable');
        if ($BitSetStatus eq 0)
        {
                vec($ReverseBitVector,$BitPosition,1) = 1;
                $FinalHexString=reverse(unpack("h".length($FsHexInputString),$ReverseBitVector));
                print "\n\nBIT ENABLED HEX STRING:              $FinalHexString AT BIT POSITION: $BitPosition\n\n";
        }
        else
        {
                exit(0);
        }
        return $FinalHexString;
}

sub FsDisableBitVector
{
        #my ($self, $FsHexInputString, $BitPosition) = @_;
        my ($FsHexInputString, $BitPosition) = @_;
        my ($NibbleMaskPattern,$Nibble,$NibblePosn,$FinalHexString);
        print "\n\nINPUT HEX STRING:                        $FsHexInputString \n\n";
        my ($BitVector,$ReverseBitVector)=GenerateBitVectors($FsHexInputString);
        my $BitUnsetStatus=ValidateBitSetUnset($FsHexInputString,$ReverseBitVector,$BitPosition,'Disable');
        if ($BitUnsetStatus eq 0)
        {
                vec($ReverseBitVector,$BitPosition,1) = 0;
                $FinalHexString=reverse(unpack("h".length($FsHexInputString),$ReverseBitVector));
                print "\n\nBIT DISABLED HEX STRING:              $FinalHexString AT BIT POSITION: $BitPosition\n\n";
        }
        else
        {
                exit(0);
        }
        return $FinalHexString;
}



print "\n\nENTER INPUT BYTE ALIGNED/NON BYTE ALIGNED HEX STRING\n";
my $InputHexStr=<STDIN>;
chomp($InputHexStr);

print "\n\nENTER OPTION Enable/Disable\n";
my $option=<STDIN>;
chomp($option);

print "\n\nENTER BIT POSITION for Enable/Disable\n";
my $BitPosn=<STDIN>;
chomp($BitPosn);

my $FsEnabledHexString=FsEnableBitVector($InputHexStr,$BitPosn) if ($option =~ /^Enable$/i);

my $FsDisabledHexString=FsDisableBitVector($InputHexStr,$BitPosn) if ($option =~ /^Disable$/i);


## Modified on 1/13/2019 9:22 PM
