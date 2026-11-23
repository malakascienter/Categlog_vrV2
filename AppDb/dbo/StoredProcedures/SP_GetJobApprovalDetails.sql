
--[dbo].[SP_GetJobApprovalDetails] 2
CREATE procedure [dbo].[SP_GetJobApprovalDetails]  
@JobHeaderID INT
AS
Begin


 
set NOCOUNT ON

--declare @JobHeaderID int=1


DECLARE @Css AS VARCHAR(MAX) = '
            <style type="text/css">

            table.gridtable {
                font-family: verdana,arial,sans-serif;
                font-size:11px;
                color:#333333;
                border-width: 1px;
                border-color: #666666;
                border-collapse: collapse;
            }

            table.gridtable th {
                border-width: 1px;
                padding: 8px;
                border-style: solid;
                border-color: #666666;
                background-color: #dedede;
            }

            table.gridtable td {
                border-width: 1px;
                padding: 8px;
                border-style: solid;
                border-color: #666666;
                background-color: #ffffff;
            }

            </style>
            '


declare @ProjectName varchar(max), @BOQName NVARCHAR(MAX),@JobCardNumber VARCHAR(MAX)
select @ProjectName=p.ProjectName, @BOQName =b.BOQName +'/V:'+ CONVERT(VARCHAR(max),b.VersionNo), @JobCardNumber =j.JobCardNumber from JobHeaders j
inner join BOQHeaders b on b.Id = j.BOQID
inner join ProjectDetails p on p.id=j.projectid
where j.id =@JobHeaderID 


declare @HeaderTable nvarchar(max)=
'<table  class="gridtable">
	<tr>
		<td>
			Project Name	:' + @ProjectName +'
		</td>
	</tr>
	<tr>
		<td>
			BOQ				:' + @BOQName +'
		</td>
	</tr>
	<tr>
		<td>
			Job Card Number :' + @JobCardNumber +'
		</td>
	</tr>
</table>'
 

 Declare @Detial nvarchar(max)=''


 Select h.id, h.Name, j.qty into #Output from JobOutputDetails j
 inner join StockItemHeaders h on h.id= j.StockItemHeaderID
 where JobHeaderID= @JobHeaderID

 declare @stockItemID int, @detail nvarchar(max)='',@itemName varchar(500), @Qty money, @inPutItemID int



 while exists(select top 1 id from #Output)
 begin
	select top 1 @stockItemID =id, @itemName = Name , @Qty=qty from #Output
	set @detail +='<TR><TD>
						<TABLE  class="gridtable">
							<TR>
							   <TH>
									'+ @itemName +'
							   </TH>
							   <TH>
									'+ convert(varchar,@Qty) +'
							   </TH>
							</TR>'
		
		Select h.id,OutPutStockItemHeaderID, h.Name, j.qty into #Input from JobInputDetails j
		inner join StockItemHeaders h on h.id= j.StockItemHeaderID
		where JobHeaderID= @JobHeaderID and j.OutPutStockItemHeaderID= @stockItemID
	
		while exists(select top 1 id from #Input)
		begin

			Select top 1 @inPutItemID=id, @itemName=Name, @Qty=qty from  #Input f 

			set @detail +=' 
							<TR>
							   <TD>
									'+ @itemName +'
							   </TD>
							   <TD>
									'+ convert(varchar,@Qty) +'
							   </TD>
							</TR>'




			delete from #Input where id= @inPutItemID
		end 
		drop table #Input
	set @detail +='		</TABLE>
				
				   </TD></TR>'


	

	delete from #Output where id= @stockItemID
 end 


 --print @detail
declare @HtmlContent nvarchar(max)=
'<TABLE  class="gridtable">
<tr>
	<td>
		'+ @HeaderTable +'
	</td>
</tr>

<tr>
	<td>
	<TABLE  class="gridtable">
	'+@detail+'
	</TABLE>
	</td>
</tr>

</Table>'

SELECT @HtmlContent

end

GO

