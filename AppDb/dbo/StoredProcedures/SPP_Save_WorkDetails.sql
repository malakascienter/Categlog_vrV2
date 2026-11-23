/*** ***************************************************************************************************** ****/
-- This procedure was Auto Genarated By A tool created by S.G. Asanga Chandrakumara
-- ON3/29/2018 10:58:34 AM
/*** ***************************************************************************************************** ****/

/*
-----------------------------------------------------
INPUTS
-----------------------------------------------------
- WHEN SAVE ADD ALL OTHER COLUMNS AS DEFAULT
- PASS @Action =1 TO INSERT OR UPDATE
- PASS @Action =2 TO DELETE
-----------------------------------------------------
OUTPUTS
-----------------------------------------------------
@status RETURNS 1 WHEN RECORD INSERTED AND NO ERRORS
@status RETURNS 2 WHEN RECORD UPDATED AND NO ERRORS
@status RETURNS 3 WHEN MORE THAN ONE RECORD DELETED AND NO ERRORS
@status RETURNS -3 WHEN DELETED SUCCESS BUT NO EFFECTED NO OF RECORDS
@status RETURNS -1 WHEN ANY KIND OF ERROR OCCURED
TO INSERT A RECORD PASS A NEGATIVE)VALUE TO @ID
*/


--exec SPP_Save_WorkDetails @Id=-1,@WorkID=5,@RateAnalysisHeaderID=4,@Quantity=2,@Rate=0,@CreatedDate='2018-10-12 09:08:15.557',@CreatedUserID=0,@IPAddress=N'',@LastModDate='2018-10-12 09:08:15.557',@LastModUserID=0,@status=-1 ,@action=1,@BoqID=1,@SaundryValue=2



CREATE PROCEDURE[dbo].[SPP_Save_WorkDetails]
 --DECLARE PARAMETERS

	@Id int,
	@WorkID int,
	@BoqID INT,
	@SaundryValue INT ,
	@RateAnalysisHeaderID int,
	@Quantity decimal(18, 2),
	@Rate decimal(18, 2),
	@IPAddress nvarchar(max),
	@CreatedUserID int,
	@LastModUserID int,
	@CreatedDate datetime,
	@LastModDate datetime,
	@Action[int],
	@status[int] OUTPUT
	
	
AS
	DECLARE @statusIN[int]
	SET @statusIN = 0;
BEGIN
BEGIN TRY
	BEGIN TRANSACTION
IF @Action =1
	BEGIN
		IF EXISTS(SELECT* FROM WorkDetails WHERE  [Id] = -999)
		BEGIN
		 --UPDATE THE RECORD
		 UPDATE WorkDetails SET
		[WorkID] = @WorkID,
		[RateAnalysisHeaderID] = @RateAnalysisHeaderID,
		[Quantity] = @Quantity,
		[Rate] = @Rate,
		[IPAddress] = @IPAddress,
		[CreatedUserID] = @CreatedUserID,
		[LastModUserID] = @LastModUserID,
		[CreatedDate] = @CreatedDate,
		[LastModDate] = @LastModDate
		WHERE [Id] = @Id
		SET @statusIN = 2
	END
	ELSE
	BEGIN
	--INSERT THE RECORD
	INSERT INTO WorkDetails(
		[WorkID],
		[RateAnalysisHeaderID],
		[Quantity],
		[Rate],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate]
		)
		VALUES
		(
		@WorkID,
		@RateAnalysisHeaderID,
		@Quantity,
		@Rate,
		@IPAddress,
		@CreatedUserID,
		@LastModUserID,
		@CreatedDate,
		@LastModDate
		)
		SELECT SCOPE_IDENTITY() AS ID
		SET @statusIN = 1;

	DECLARE @Descriptions varchar(max)

	SELECT @Descriptions=Description FROM dbo.RateAnalysisHeaders WHERE Id=@RateAnalysisHeaderID
	

		INSERT INTO dbo.BOQRateanalysisAllocationHeaders
		        ( BOQID ,
		          WorkID ,
		          RateQtyInWork ,
		          RateAnalysisID ,
		          Description ,
		          TotalPrice ,
		          Status ,
		          CreateUserId ,
		          CreateDate ,
		          AllocationUserID ,
		          AllocationDate ,
		          ProfitMarginPer ,
		          ProfitMarginVal ,
		          OverheadCostPer ,
		          OverheadCostVal,
				  SundryValue
		        )
		VALUES  ( @BoqID , -- BOQID - int
		          @WorkID , -- WorkID - int
		          @Quantity , -- RateQtyInWork - float
		          @RateAnalysisHeaderID , -- RateAnalysisID - int
		          @Descriptions , -- Description - nvarchar(max)
		          0.0 , -- TotalPrice - float
		          1 , -- Status - bit
		          @CreatedUserID , -- CreateUserId - int
		          GETDATE() , -- CreateDate - datetime
		          @CreatedUserID , -- AllocationUserID - int
		          GETDATE() , -- AllocationDate - datetime
		          0.0 , -- ProfitMarginPer - float
		          0.0 , -- ProfitMarginVal - float
		          0.0 , -- OverheadCostPer - float
		          0.0 ,
				  @SaundryValue -- OverheadCostVal - float
		        )
				--add exsisting details
				IF NOT EXISTS(SELECT ID FROM dbo.BOQRateanalysisAllocationDetails WHERE BOQID=@BoqID  AND RateID=@RateAnalysisHeaderID)
				BEGIN
				INSERT INTO dbo.BOQRateanalysisAllocationDetails
					
		        ( BOQID ,
		          RateID ,
		          SequNo ,
		          Location ,
		          ItemID ,
		          ItemType ,
		          Unit ,
		          UnitPrice ,
		          Quantity,
				  Currency,
				  ExchangeRate,
				  PackID ,
				  PackQty ,
				  PackRate ,
				  PackBreakdownQty,
				  IsProfitMarg,
				  ProfitMarginPercentage,
				  OverheadCostVal,
				  ProfitMarginVal,
				  DiscountValue,
				  IsPercentageOrValue,
				  DiscountPercentage,
				  OHCPercentage,
				  ISOHCPercentage
		        )
				SELECT @BoqID,RateAnalysisHeaderID,SequNo,LocationID,ItemHeaderID,ItemType,UnitID,UnitPrice,Quantity,Currency,ExchangeRate,PackID ,
				  PackQty ,
				  PackRate ,
				  PackBreakdownQty,IsProfitMarg,ProfitMarginPercentage,OverheadCostVal,ProfitMarginVal,DisValue,isDisRate,DiscountPercentage,OHCPercentage, IsOHCPercentage
				   FROM dbo.RateAnalysisDetails WHERE RateAnalysisHeaderID=@RateAnalysisHeaderID	
				end
				
				--select * from [dbo].[CostProvisionSnapShot]
				--select * from [dbo].[CostProvisions]
				IF NOT EXISTS(SELECT ID FROM dbo.CostProvisionSnapShot WHERE BOQID=@BoqID  AND RateHeaderId=@RateAnalysisHeaderID)
				BEGIN
				INSERT INTO [dbo].[CostProvisionSnapShot]
						   ([RateHeaderId],
							[Cost],
							[CategoryId],
							[Percentage],
							[ItemId],
							[BoqId],
							[OHPercentage])
					select RateHeaderId,Cost,CategoryId,Percentage,ItemId,@BoqID,OHPercentage from costprovisions where  RateHeaderId=@RateAnalysisHeaderID
				END

				--add to mrnitemregistry

				DECLARE @ProjectID INT,@DepartmentID INT

				SELECT @ProjectID=ProjectID FROM dbo.BOQHeaders WHERE Id=@BoqID				
				SELECT @DepartmentID=DepartmentID FROM dbo.BOQSubWorkAllocations WHERE BOQID=@BoqID AND Id=@WorkID


				SELECT  'Quantity', @Quantity

				--UPDATE dbo.MRNItemRegistries SET BOQQuantity=BOQQuantity+(Quantity*@Quantity),BalanceQuantity=BalanceQuantity+(Quantity*@Quantity),LastModDate=RD.LastModDate FROM dbo.BOQRateanalysisAllocationDetails AS RD
				--INNER JOIN  dbo.MRNItemRegistries AS MTR ON MTR.ItemId=RD.ItemID  WHERE RateID=@RateAnalysisHeaderID AND ItemType='I' AND MTR.BOQId=@BoqID AND MTR.DepId=@DepartmentID AND MTR.ProjectID=@ProjectID


				--INSERT INTO dbo.MRNItemRegistries
				--        ( ItemId ,
				--          BOQId ,
				--          DepId ,
				--          BOQQuantity ,
				--          RequestQuantity ,
				--          IssueQuantity ,
				--          BalanceQuantity ,
				--          SuspendedQuantity ,
				--          IPAddress ,
				--          CreatedUserID ,
				--          LastModUserID ,
				--          CreatedDate ,
				--          LastModDate ,
				--          ProjectID,
				--		  UnitID
				--        )
			

				--SELECT RD.ItemHeaderID,@BoqID,@DepartmentID,RD.Quantity*@Quantity,0,0,RD.Quantity*@Quantity,0,@IPAddress,@CreatedUserID,@LastModUserID,@CreatedDate,@LastModDate,@ProjectID,RD.UnitID FROM dbo.RateAnalysisDetails AS RD
				--LEFT JOIN  dbo.MRNItemRegistries AS MTR ON MTR.ItemId=RD.ItemHeaderID AND MTR.BOQId = @BoqID AND MTR.DepId = @DepartmentID AND MTR.ProjectID = @ProjectID  WHERE RateAnalysisHeaderID=@RateAnalysisHeaderID AND ItemType='I' AND MTR.ItemId IS NULL 


	END
	END --ACTION 2 ENDS
ELSE IF @Action = 2
	BEGIN
		DELETE [WorkDetails] WHERE [Id] = @Id
	IF @@ROWCOUNT >0 
	BEGIN
		SET @statusIN = 3;
	END
	ELSE
	BEGIN
		SET @statusIN = -3;
	END
END --ACTIION -3 ENDS
	COMMIT TRAN -- Transaction Success!
	SET @status = @statusIN
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
	SET @status = -1;
		SELECT
		ERROR_NUMBER() AS ErrorNumber
		,ERROR_SEVERITY() AS ErrorSeverity
		,ERROR_STATE() AS ErrorState
		,ERROR_PROCEDURE() AS ErrorProcedure
		,ERROR_LINE() AS ErrorLine
	,ERROR_MESSAGE() AS ErrorMessage
END CATCH
END--SP ENDS

GO

