CREATE PROCEDURE[dbo].[SPP_Update_BOQName]
 --DCLARE PARAMETERS

	@Id int,	
	@BOQName VARCHAR(max),
	@OHPmaterial decimal(18,2),	
	@OHPlabour decimal(18,2),	
	@status[int] OUTPUT,
	@PropertyID INT

AS
	DECLARE @statusIN[int]
	SET @statusIN = 0;
BEGIN
BEGIN TRY
	BEGIN TRANSACTION
	DECLARE @BOQMAINID INT

	

	select @BOQMAINID=MainBoqId from BOQHeaders WHERE BOQHeaders.Id=@Id
	UPDATE BOQHeaders
	SET BOQName = @BOQName
    WHERE BOQHeaders.MainBoqId=@BOQMAINID
		SET @statusIN = 1;

	
	Update BOQHeaders
	SET OHPmaterial = @OHPmaterial,OHPlabour=@OHPlabour
	Where BOQHeaders.Id=@Id

	update BOQSubWorkAllocations set OHPValue=case when @OHPmaterial <>0 then SundryAmount*@OHPmaterial/100 else 0 end

	update BOQRateanalysisAllocationDetails set 
	OverheadCostVal = case when  @OHPmaterial<>0  then  (UnitPrice+UnitTax)*@OHPmaterial/100 else 0 end,
	ISOHCPercentage=1,
	OHCPercentage = @OHPmaterial
	Where BOQID=@Id AND ItemType='I'
		
	
	update BOQRateanalysisAllocationDetails set 
	OverheadCostVal = case when  @OHPlabour<>0  then  (UnitPrice+(UnitPrice*UnitTax)/100)*@OHPlabour/100 else 0 end,
	ISOHCPercentage=1,
	OHCPercentage = @OHPlabour
	Where BOQID=@Id AND ItemType='L'

	update [dbo].[CostProvisionSnapShot] set OHPercentage=case when @OHPmaterial<>0  then  @OHPmaterial else 0 end
	Where BoqId=@Id 

	

	EXEC TotalRecalculateBOQ @Id

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

