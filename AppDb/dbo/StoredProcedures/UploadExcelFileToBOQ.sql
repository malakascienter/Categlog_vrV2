CREATE  procedure [dbo].[UploadExcelFileToBOQ] (@BOQID int , @UserID int , @fileName varchar(max))
as
declare @DocumentNo varchar(100)

create table #TEMPBOQ(	ID int not null identity(1,1),SEC int, WO int, RA int, ITEM varchar(100), Description varchar(max), InsertID int,Processed bit  not null  default 0  )

declare @sql as nvarchar(max)

set @sql ='insert into #TEMPBOQ (SEC,WO,RA,ITEM,Description ) 
SELECT * 
FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',''Excel 12.0; Database='+@fileName+''' , [BOQ$])
where SE is not null'

print @sql
 
EXEC sp_executesql    @sql




declare @SEC int, @description varchar(max) , @WO int, @RA int, @ITEM varchar(100), @InsertID int , @id int , @status int  

select * from #TEMPBOQ  

while exists (select top (1) * from #TEMPBOQ where WO is null and ra is null and processed = 0)
begin
 
	select top (1) @SEC= sec, @description = description, @Id = id 
	from  #TEMPBOQ where WO is null and ra is null and processed = 0

	print 'BOQMainWorkAllocations'
	
	INSERT INTO BOQMainWorkAllocations(
		[BOQID],
		[Description]
		)
		VALUES
		(
		@BOQID,
		@Description
		)

		set  @InsertID= SCOPE_IDENTITY()
	 
	declare @S as int =1, @WID int , @WinsertID int 
	while Exists (select top (1) * from #TEMPBOQ where WO is not null and ra is null and processed = 0 and sec= @SEC)
	begin

	select top (1) @WID=ID,@WO= WO, @description = description from #TEMPBOQ where WO is not null and ra is null and processed = 0 and sec= @SEC
		print 'BOQSubWorkAllocations'

		select @DocumentNo= dbo.FN_GetNextDocumentNumber (1,-9999,'WK')

		INSERT INTO [dbo].[WorkHeaders]
			   ([Description],[IPAddress],[CreatedUserID],[LastModUserID],[CreatedDate],[LastModDate],[WorkHeaderStatus],[WorkCode])
		 VALUES
			   (@description,'',@UserID,@UserID,GETDATE(),GETDATE(),0,@DocumentNo)
		
		INSERT INTO BOQSubWorkAllocations([BOQID],[Description],[Quantity],[Rate],[DepartmentID],[Awarded],[SeqNo],[WorkID],[MainWorkID])
		VALUES (@BOQID,@Description,1,0,1,0,@s,@WO,@InsertID)

		--Update  doc number tables

		set @WinsertID=SCOPE_IDENTITY() 

			declare  @RID  int 
			while  exists (select top (1) * from #TEMPBOQ where   RA is not null and processed = 0 and sec= @SEC and WO= @WO)
			begin


			declare @PropertyID int=1

 

			 SELECT @DocumentNo= dbo.FN_GetNextDocumentNumber (@PropertyID,-9999,'R9')
  
--SELECT * FROM TransactionTypeWiseNextNumbers
   UPDATE TransactionTypeWiseNextNumbers
   SET NextNumber=NextNumber+1
    WHERE locationid=-9999 and transactionType='R9'
	--INSERT THE RECORD
	INSERT INTO RateAnalysisHeaders(
		[Description],
		[RateAnalysisHeaderStatus],
		[ProfitMarginPer],
		[ProfitMarginVal],
		[OverheadCostPer],
		[OverheadCostVal],
		[RateCode],
		[TotalCost],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate]
		)
		VALUES
		(
		@Description,
		1,
		0,
		0,
		0,
		0,
		'R'+@DocumentNo,
		0,
		0,
		0,
		0,
		GETDATE(),
		GETDATE()
		)

		SET @RA= SCOPE_IDENTITY() 



			select top (1) @RID=ID,  @description = description from #TEMPBOQ where RA is not null and processed = 0 and sec= @SEC and WO=@WO
			--print 'BOQRateanalysisAllocationHeaders'
			--INSERT INTO dbo.BOQRateanalysisAllocationHeaders
		 --   ( BOQID ,
		 --       WorkID ,
		 --       RateQtyInWork ,
		 --       RateAnalysisID ,
		 --       Description ,
		 --       TotalPrice ,
		 --       Status ,
		 --       CreateUserId ,
		 --       CreateDate ,
		 --       AllocationUserID ,
		 --       AllocationDate ,
		 --       ProfitMarginPer ,
		 --       ProfitMarginVal ,
		 --       OverheadCostPer ,
		 --       OverheadCostVal,
			--	SundryValue

		 --   )
			--VALUES  ( 
			--	@BoqID , -- BOQID - int
		 --       @WinsertID , -- WorkID - int
		 --       1 , -- RateQtyInWork - float
		 --       @RA , -- RateAnalysisID - int
		 --       @description , -- Description - nvarchar(max)
		 --       0.0 , -- TotalPrice - float
		 --       1 , -- Status - bit
		 --       @UserID , -- CreateUserId - int
		 --       GETDATE() , -- CreateDate - datetime
		 --       @UserID , -- AllocationUserID - int
		 --       GETDATE() , -- AllocationDate - datetime
		 --       0.0 , -- ProfitMarginPer - float
		 --       0.0 , -- ProfitMarginVal - float
		 --       0.0 , -- OverheadCostPer - float
		 --       0.0 ,
			--	0 -- OverheadCostVal - float
		 --   )
			
				

				update #TEMPBOQ 
				set processed = 1, InsertID = SCOPE_IDENTITY()  
				where id = @RID
			end 
			


			

			update #TEMPBOQ set processed = 1, InsertID = @WinsertID 
			where id = @WID

	end 

	update #TEMPBOQ set processed = 1, InsertID = @InsertID where id = @id
end

GO

