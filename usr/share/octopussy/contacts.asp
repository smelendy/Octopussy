<WebUI:PageTop title="_CONTACTS" help="contacts" />
<%
my $f = $Request->Form();
my $cid = $f->{cid} || $Request->QueryString("cid");
my $action = $f->{action} || $Request->QueryString("action");
my $sort = $Request->QueryString("contacts_table_sort") || "cid";	

if ((NOT_NULL($action)) && ($action eq "edit")   
            && ($Session->{AAT_ROLE} !~ /ro/i))
{
%><AAT:Inc file="octo_contact_edit" contact="$cid" url="./contacts.asp" /><%
}
else
{
	if ((NOT_NULL($action)) && ($action eq "remove") 
		&& ($Session->{AAT_ROLE} !~ /ro/i))
	{
		Octopussy::Contact::Remove($cid);
		AAT::Syslog::Message("octo_WebUI", "GENERIC_DELETED", "Contact", 
			$cid, $Session->{AAT_LOGIN});
		$Response->Redirect("./contacts.asp");
	}
	elsif ((NOT_NULL($action)) && ($action eq "new") 
			&& ($Session->{AAT_ROLE} !~ /ro/i))
	{
 		$Session->{AAT_MSG_ERROR} = Octopussy::Contact::New( { 
			cid => $cid, lastname => Encode::decode_utf8($f->{lastname}), 
    		firstname => Encode::decode_utf8($f->{firstname}),
  			description => Encode::decode_utf8($f->{description}), 
    		email => $Server->HTMLEncode($f->{email}), im => $f->{im} } );
		AAT::Syslog::Message("octo_WebUI", "GENERIC_CREATED", "Contact", 
			$cid, $Session->{AAT_LOGIN})	
			if (NULL($Session->{AAT_MSG_ERROR}));
		$Response->Redirect("./contacts.asp");
	}
	elsif ((NOT_NULL($action)) && ($action eq "update")
            && ($Session->{AAT_ROLE} !~ /ro/i))
	{
		Octopussy::Contact::Remove($cid);
		$Session->{AAT_MSG_ERROR} = Octopussy::Contact::New( {
            cid => $cid, lastname => Encode::decode_utf8($f->{lastname}),
            firstname => Encode::decode_utf8($f->{firstname}),
            description => Encode::decode_utf8($f->{description}),
            email => $Server->HTMLEncode($f->{email}), im => $f->{im} } );
		AAT::Syslog::Message("octo_WebUI", "GENERIC_MODIFIED", "Contact",
            $cid, $Session->{AAT_LOGIN})
            if (NULL($Session->{AAT_MSG_ERROR}));
		$Response->Redirect("./contacts.asp");
	}
%><AAT:Inc file="octo_contacts_list" url="./contacts.asp" sort="$sort" /><%
}
%>
<WebUI:PageBottom />
