create procedure [dbo].[InsertTransactionWiseSerialNumbers](@XMLDetails xml)
as

BEGIN TRY

	declare @iDocID int


	EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;


	select ID, LocationID, StockItemHeaderID, TxnID, TxnType, SerialNumber, OutTxnID, OutTxnType, Out
	into #TempData   
	FROM OPENXML(@iDocID, 'ArrayOfSerialModel/SerialModel', 2)
	with (ID int, LocationID int, StockItemHeaderID int, TxnID int, TxnType char(2), SerialNumber varchar(max), OutTxnID int, OutTxnType char(2), Out bit)


	declare @ID int, @LocationID int, @StockItemHeaderID int, @TxnID int, @TxnType char(2), @SerialNumber varchar(max), 
			@OutTxnID int, @OutTxnType char(2), @Out bit
	
	

	While exists(select top (1) ID from #TempData)
	begin

		select top (1)	@ID =ID, @LocationID =LocationID , @StockItemHeaderID =StockItemHeaderID , @TxnID =TxnID , @TxnType =TxnType , @SerialNumber =SerialNumber , 
							@OutTxnID =OutTxnID , @OutTxnType =OutTxnType , @Out =Out 
		from #TempData

		if @Out=0 
		begin
			
			 insert into [dbo].[TransactionWiseSerialNumbers]
			 (LocationID, StockItemHeaderID, TxnID, TxnType, TxnDate, SerialNumber, OutTxnID, OutTxnType)
			 values 
			 (@LocationID , @StockItemHeaderID , @TxnID , @TxnType,getdate(), @SerialNumber,@OutTxnID, @OutTxnType)
		end 
		else
		begin
			
			update [TransactionWiseSerialNumbers] 
			set OutTxnID= @OutTxnID, OutTxnType=@OutTxnType, Out=1, OutTxndate=getdate()
			where locationID =@LocationID and StockItemHeaderID=@StockItemHeaderID and SerialNumber=@SerialNumber

		end


		delete from #TempData 
		where [LocationID] = @LocationID and [StockItemHeaderID] = @StockItemHeaderID and [SerialNumber] = @SerialNumber

	end 



	update stocktransactiondetails set IsSerialAdded =1 where stockitemId=@StockItemHeaderID and stocktransactionheaderid=@TxnID

	

END TRY
BEGIN CATCH
 
	INSERT INTO dbo.Error_List (OccuredDateTime,ErrorNo,ErrorLine,Error,ErrorProcedure) VALUES (SYSDATETIME(),ERROR_NUMBER(),ERROR_LINE(),ERROR_MESSAGE(),ERROR_PROCEDURE()); 		
	
	DECLARE @ErrorMessage NVARCHAR(4000);  
    DECLARE @ErrorSeverity INT;  
    DECLARE @ErrorState INT;  

		SELECT   
        @ErrorMessage = ERROR_MESSAGE(),  
        @ErrorSeverity = ERROR_SEVERITY(),  
        @ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
		  
END CATCH

GO

