CREATE PROCEDURE[dbo].[SP_SaveOldBOQRate]
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
	@status[int] OUTPUT,
	@BoqOLDID int
	
	
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

	DECLARE @Descriptions varchar(max),@OHPMaterial Decimal,@OHPLabour Decimal

	Select @OHPMaterial=OHPmaterial,@OHPLabour=OHPlabour from BOQHeaders where Id=@BoqID


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
				SELECT @BoqID,RateID,SequNo,Location,ItemID,ItemType,Unit,UnitPrice,Quantity,Currency,ExchangeRate,PackID ,
				  PackQty ,
				  PackRate ,
				  PackBreakdownQty,IsProfitMarg,ProfitMarginPercentage,OverheadCostVal,ProfitMarginVal,DiscountValue,IsPercentageOrValue,DiscountPercentage,OHCPercentage, ISOHCPercentage
				   FROM dbo.BOQRateanalysisAllocationDetails WHERE RateID=@RateAnalysisHeaderID	and BOQID=@BoqOLDID
				end
				

				


				--select * from [dbo].[CostProvisionSnapShot]
				--select * from [dbo].[CostProvisions]
				IF NOT EXISTS(SELECT ID FROM dbo.BOQRateanalysisAllocationDetails WHERE BOQID=@BoqID  AND RateID=@RateAnalysisHeaderID)
				BEGIN
				INSERT INTO [dbo].[CostProvisionSnapShot]
						   ([RateHeaderId],
							[Cost],
							[CategoryId],
							[Percentage],
							[ItemId],
							[BoqId])
					select RateHeaderId,Cost,CategoryId,Percentage,ItemId,@BoqID from CostProvisionSnapShot
					where  RateHeaderId=@RateAnalysisHeaderID and BoqId=@BoqOLDID
				END

					update BOQRateanalysisAllocationDetails set 
					OverheadCostVal = case when  @OHPMaterial<>0  then  UnitPrice*@OHPmaterial/100 else 0 end,
					ISOHCPercentage=1,
					OHCPercentage = @OHPmaterial
					Where BOQID=@BoqID AND ItemType='I' AND RateID=@RateAnalysisHeaderID
		
	
					update BOQRateanalysisAllocationDetails set 
					OverheadCostVal = case when  @OHPlabour<>0  then  UnitPrice*@OHPlabour/100 else 0 end,
					ISOHCPercentage=1,
					OHCPercentage = @OHPmaterial
					Where BOQID=@BoqID AND ItemType='L' AND RateID=@RateAnalysisHeaderID
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

