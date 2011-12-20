use strict;
use warnings;
use Carp;
use Win32::OLE qw/EVENTS/;
use FindBin;

$|++;

my $XASession = Win32::OLE->new('XA_Session.XASession')
    or croak Win32::OLE->LastError();

my $XASessionEvents = sub {
    my ($obj, $event, @args) = @_;
    # 1: OnLogin, 2: OnLogout, 3: OnDisconnect
    if ($event == 1) {
	my ($code, $msg) = @args;
	print "XASession Login Event: [$code] $msg \n";
	Win32::OLE->QuitMessageLoop();
    } elsif ($event ==2) {
	print "XASession Logout Event: @args \n";
	Win32::OLE->QuitMessageLoop();
    } elsif ($event == 3) {
	print "XASession Disconnect Event: @args \n";
	Win32::OLE->QuitMessageLoop();
    }
};

Win32::OLE->WithEvents($XASession, $XASessionEvents, '{6D45238D-A5EB-4413-907A-9EA14D046FE5}'); 

croak Win32::OLE->LastError() if Win32::OLE->LastError() != 0;

my $server  = 'demo.etrade.co.kr';	# ���� ���� ���� �ּ�
my $port    = 20001;			# ���� ��Ʈ
my $user    = '';		# ��Ʈ���̵� ���� ���̵�
my $pass    = '';		# ��Ʈ���̵� ���� ��ȣ
my $certpwd = '';			# ���� ������ ��ȣ
my $srvtype = 1;			# ���� Ÿ��

my $showcerterr = 1;

$XASession->ConnectServer($server, $port)
    or croak $XASession->GetErrorMessage( $XASession->GetLastError );

$XASession->Login($user, $pass, $certpwd, $srvtype, $showcerterr)
    or croak $XASession->GetErrorMessage( $XASession->GetLastError );

Win32::OLE->MessageLoop();

####
my $XAReal = Win32::OLE->new('XA_DataSet.XAReal.1')
    or croak Win32::OLE->LastError();

$XAReal->LoadFromResFile("$FindBin::Bin/res/H1_.res")
    or croak Win32::OLE->LastError();

my $XARealEvents = sub {
    my ($obj, $event, @args) = @_;
    # 1: OnReceiveRealData
    if ($event == 1) {
	my $trname = $args[0];

	my $hotime   = $obj->GetFieldData('OutBlock', 'hotime');
	my $offerho1 = $obj->GetFieldData('OutBlock', 'offerho1');
	my $bidho1   = $obj->GetFieldData('OutBlock', 'bidho1');

	print "OnReceiveRealData: $trname\n";
	print "[$hotime $offerho1 $bidho1]\n";
    }
};

Win32::OLE->WithEvents($XAReal, $XARealEvents, '{16602768-2C96-4D93-984B-E36E7E35BFBE}');

croak Win32::OLE->LastError() if Win32::OLE->LastError() != 0;

$XAReal->SetFieldData('InBlock', 'shcode', '000270');

$XAReal->AdviseRealData();

Win32::OLE->MessageLoop();
