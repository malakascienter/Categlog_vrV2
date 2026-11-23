CREATE Procedure [dbo].[SP_UpdateDocNo]
(
	@TableName varchar(500)
)
as 
Declare @TDocNo varchar(5)
select @TDocNo = rtrim(ltrim(ltrim(rtrim(prifix))+RIGHT('0000000' + CAST(CAST(NextNo  AS INT) AS VARCHAR(20)),FeildLegnth))) from TableCodeSetUps where IsCodeAutoGenerate=1 and TAblename= @TableName
	if @@ROWCOUNT >0
	begin
	   
	    update TableCodeSetUps set NextNo=NextNo+1 where IsCodeAutoGenerate=1 and TAblename= @TableName
	end
	
	select @TDocNo

GO

