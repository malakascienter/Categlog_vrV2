--EXEC [PrintMyBill] '<Bill><Line><SEQ>1</SEQ><LineTypeID>11</LineTypeID><LineContent><PrintData ID="1" Data="AmountReceived : 6100.00" /></LineContent></Line><Line><SEQ>2</SEQ><LineTypeID>12</LineTypeID><LineContent><PrintData ID="2" Data="Cash : 1100.00" /></LineContent></Line><Line><SEQ>3</SEQ><LineTypeID>13</LineTypeID><LineContent><PrintData ID="3" Data="CashBalance : 4950.48" /></LineContent></Line><Line><SEQ>4</SEQ><LineTypeID>14</LineTypeID><LineContent><PrintData ID="4" Data="CreditAmount : 0.00" /></LineContent></Line><Line><SEQ>5</SEQ><LineTypeID>15</LineTypeID><LineContent><PrintData ID="5" Data="Discount : 0.00" /></LineContent></Line><Line><SEQ>6</SEQ><LineTypeID>16</LineTypeID><LineContent><PrintData ID="6" Data="GrandTotal : 6050.48" /></LineContent></Line><Line><SEQ>7</SEQ><LineTypeID>17</LineTypeID><LineContent><PrintData ID="7" Data="SubTotal : 6050.4800" /></LineContent></Line></Bill>'
CREATE procedure [dbo].[PrintMyBill] (@bill as xml=null)
as


SET NOCOUNT ON

declare @PrintTable as Table (ID int identity(1,1), TextLine varchar(max))

declare @Lines as table (SEQ int, LineTypeID int, Data varchar(max),ID int)

declare @iDocID int

EXEC sp_xml_preparedocument @iDocID OUTPUT,@bill

insert into @Lines
select  *
FROM     OPENXML (@iDocID,'Bill/Line/LineContent/PrintData',2)
with (SEQ int '../../SEQ', LineTypeID int '../../LineTypeID', Data varchar(max) '@Data',ID int '@ID')
order by SEQ, ID





EXEC sp_xml_removedocument @iDocID 
 
 

declare @SEQ INT, @LineLength INT

SELECT TOP (1) @LineLength =CharactersPerLine 
FROM dbo.PrintingCommands pc 
INNER JOIN dbo.LineTypes l ON l.PrintType= pc.ID
INNER JOIN 		 @Lines t ON t.LineTypeID= l.ID





--declare @lineText as varchar(85), @LastLine int =1, @line int ,@Col int , @LineTypeID int , @data varchar(max)
declare @lineText as varchar(96), @LastLine int =1, @line int ,@Col int , @LineTypeID int , @data varchar(max)
While (select COUNT(*) from @Lines)>0
begin

    --select @line , @LastLine , @LineText

    select top (1) @seq = seq, @line =Seq, @Col = id from @Lines
    order by seq,id

    if @line <> @LastLine and @LineText is not null 
    begin
         
        print @LineText
        insert @PrintTable (TextLine) Values (@LineText)
        set @LineText=''
    end 

    
    select @data = +Data,@LineTypeID= LineTypeID 
    from @Lines where seq= @seq and id=@Col
    
 
    set  @lineText= isnull(@lineText,'') + dbo.FormatPrintText(@linetypeid,@col, @data)
    
    --set  @lineText= isnull(@lineText,'') + @data

    set @LastLine= @line
 
    delete from @Lines where SEQ=@line and id = @Col

    
end 

print @lineText
insert @PrintTable (TextLine) Values (@LineText)
    
select * from @PrintTable

GO

