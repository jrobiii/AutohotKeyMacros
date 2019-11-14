;; SQL Server
#IfWinActive Microsoft SQL Server Management Studio

:*:rwn::raiserror ('', 0, 1) with nowait
:*:ij::inner join
:*:loj::left outer join
::stil::set transaction isolation level read uncommitted
::bt::begin transaction
::rt::rollback transaction
::stt::select top 100 * from 
::newproc::
    Clip("if object_id('<Procedure Name, sysname, NewProc>') is null begin `n    declare @SqlCmd varchar(max) = 'create procedure <Procedure Name, sysname, NewProc> as select 1'`n    exec (@SqlCmd)`nend `ngo `n`nalter procedure <Procedure Name, sysname, NewProc>`n     @_<First Parameter, sysname, Parameter1> <First Parameter Type,,datetime><First Parameter Default Value,, = null >`n    ,@_<Second Parameter, sysname, Parameter2> <Second Parameter Type,,sysname><Second Parameter Default Value,, = null >`nas begin `n    set nocount on`n    declare @ErrorMessage varchar(max)`n`n    -- Some preprocessing stuff can go here`n    raiserror ('<Procedure Name, sysname, NewProc>: Procedure starting', 0, 1) with nowait`n    begin try`n        -- This is where the guts goes.`n        select @_<First Parameter, sysname, Parameter1>, @_<Second Parameter, sysname, Parameter2>`n`n    end try `n    begin catch `n        -- Basic error handling...`n        set @ErrorMessage = concat('<Procedure Name, sysname, NewProc>: An error was encountered.  ErrorNumber: ', error_number(), ', ErrorMessage: ', error_message())`n        raiserror ('%s', 16, 1, @ErrorMessage) with nowait`n        return -1`n    end catch`n    raiserror ('<Procedure Name, sysname, NewProc>: Procedure completed successfully', 0, 1) with nowait`nend`n`n/*`n`nexecute <Procedure Name, sysname, NewProc>`n     @_<First Parameter, sysname, Parameter1> <First Parameter Default Value,, = null >`n    ,@_<Second Parameter, sysname, Parameter2> <First Parameter Default Value,, = null >`n`n*/")
    SendInput +^m
    Return
::sql.loop::
    Clip("`ndeclare @<Base Table, sysname,> table (`n    <Iterator Field, sysname,> sysname not null primary key clustered`n)`n    `ninsert into @<Base Table, sysname,>`n    <Query to Populate Base Table, query,>`n`ndeclare @<Iterator Field, sysname,> sysname = (select min(<Iterator Field, sysname,>) from @<Base Table, sysname,>)`n`nwhile (@<Iterator Field, sysname,> is not null) begin `n    print @<Iterator Field, sysname,> `n    set @<Iterator Field, sysname,> = (select min(<Iterator Field, sysname,>) from @<Base Table, sysname,> where <Iterator Field, sysname,> > @<Iterator Field, sysname,> )`nend`n`n")
    SendInput +^m
    Return
::tt::
    Clip("if (object_id('tempdb..#<Table Name, sysname, >') is not null ) drop table #<Table Name, sysname, >`ncreate table #<Table Name, sysname, > (`n     <Table Name, sysname, >Id int identity (1, 1) primary key clustered`n    ,<Table Name, sysname, >Name sysname not null`n)")
    SendInput +^m
    Return
::btrt::begin transaction`nrollback transaction
::newtable::
    Clip("create table <Schema Name, sysname, >.<Table Name, sysname, > ( `n     <Table Name, sysname, >Id int identity(1, 1)`n    ,<Table Name, sysname, >Name sysname not null `n    ,constraint PK_<Table Name, sysname, > primary key clustered (<Table Name, sysname, >Id)`n    ,constraint UQ_<Table Name, sysname, >_<Table Name, sysname, >Name unique (<Table Name, sysname, >Name)`n)`n")
    SendInput +^m
    Return
::newtv::
    Clip("declare @<Table Name, sysname, > table ( `n     <Table Name, sysname, >Id int identity(1, 1) primary key clustered `n    ,<Table Name, sysname, >Name sysname not null `n)`n`ninsert into @<Table Name, sysname, >(<Table Name, sysname, >Name)`n    values `n        ('')`n")
    SendInput +^m
    Return
; Block comment highlighted text
^1::Clip("/*`n" Clip() "`n*/") 
::tabcol::
    Clip("select `n    object_name(sc.object_id) as TableName`n    ,name as ColumnName`nfrom `n    sys.columns sc `nwhere`n    sc.name like '%<Partial Column Name, sysname, Group>%'`n order by `n    object_name(sc.object_id)`n    ,name`n")
    SendInput +^m
    Return
:*:sst::
    SendInput select top 100 * from 
    return

#IfWinActive
