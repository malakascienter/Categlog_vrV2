-- [dbo].[SP_InsertPackageMetirials] '<ArrayOfRateAnalysisDetailsmodel2 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><RateAnalysisDetailsmodel2><IPAddress>192.168.0.2</IPAddress><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2019-07-01T09:00:50.005Z</CreatedDate><LastModDate>2019-07-01T09:00:50.005Z</LastModDate><Id>150</Id><RateAnalysisHeaderID>102</RateAnalysisHeaderID><BoqId>20</BoqId><SequNo>1</SequNo><LocationID>0</LocationID><ItemHeaderID>765</ItemHeaderID><ItemType>P</ItemType><UnitID>0</UnitID><UnitPrice>10</UnitPrice><Quantity>2</Quantity><ProfitMarginVal>1</ProfitMarginVal><OverheadCostVal>2</OverheadCostVal><isDisRate>false</isDisRate><DisValue>0</DisValue><ItemName>BATTARY 12V FOR FIRE ALARM PANEL</ItemName><Name /><isProjectspecificSubstituteItem>true</isProjectspecificSubstituteItem><Currency>0</Currency><ExchangeRate>0</ExchangeRate><PackID>1010</PackID><PackQty>2</PackQty><PackRate>2.5</PackRate><PackBreakdownQty>0.8</PackBreakdownQty></RateAnalysisDetailsmodel2></ArrayOfRateAnalysisDetailsmodel2>',-1,1
CREATE procedure [dbo].[SP_InsertPackageMetirials](@XmLdata as xml, @status int OUTPUT,@Action INT)
as

--BEGIN TRY
--	BEGIN TRANSACTION trans1


	declare @DocId int ,
	@Id INT ,
    @RateAnalysisHeaderID INT ,
    @BoqID INT ,
    @SequNo INT ,
    @LocationID INT ,
    @ItemHeaderID INT ,
    @ItemType NVARCHAR(1) ,
    @UnitID INT ,
    @UnitPrice DECIMAL(18, 2) ,
    @Quantity DECIMAL(18, 2) ,
    @ProfitMarginVal DECIMAL(18, 2) ,
    @OverheadCostVal DECIMAL(18, 2) ,
    @isDisRate BIT ,
    @isProjectspecificSubstituteItem BIT ,
    @DisValue DECIMAL(18, 2) ,
    @IPAddress NVARCHAR(MAX) ,
    @CreatedUserID INT ,
    @LastModUserID INT ,
    @CreatedDate DATETIME ,
    @LastModDate DATETIME ,
   -- @Action [INT] ,
    @ProjectID INT ,
    @DeptID INT=1 ,
    @PropertyID INT ,
    @WorkDetailID INT,
	@Currency INT,
	@ExchangeRate Decimal(18,2),
	@PackID int,
	@PackQty Decimal(18,2),
	@PackRate Decimal(18,2),
	@PackBreakdownQty Decimal(18,2),
	@IsProfitMarg bit,
	@DiscountPercentage Decimal(18,2),
	@ProfitMarginPercentage Decimal(18,2)
	


	EXEC sp_xml_preparedocument @DocId  OUTPUT, @XmlData

	SELECT   * into #Temdata
	FROM      OPENXML (@DocId, 'ArrayOfRateAnalysisDetailsmodel2/RateAnalysisDetailsmodel2',2)  
           WITH ( Id INT ,
    RateAnalysisHeaderID INT ,
    BoqId INT ,
    SequNo INT ,
    LocationID INT ,
    ItemHeaderID INT ,
    ItemType NVARCHAR(1) ,
    UnitID INT ,
    UnitPrice DECIMAL(18, 2) ,
    Quantity DECIMAL(18, 2) ,
    ProfitMarginVal DECIMAL(18, 2) ,
    OverheadCostVal DECIMAL(18, 2) ,
    isDisRate BIT ,
    isProjectspecificSubstituteItem BIT ,
    DisValue DECIMAL(18, 2) ,
    IPAddress NVARCHAR(MAX) ,
    CreatedUserID INT ,
    LastModUserID INT ,
    CreatedDate DATETIME ,
    LastModDate DATETIME ,
   -- Action [INT] ,
    ProjectID INT ,
    DeptID INT ,
    PropertyID INT ,
    WorkDetailID INT,
	Currency INT,
	ExchangeRate Decimal(18,2),
	PackID int,
	PackQty Decimal(18,2),
	PackRate Decimal(18,2),
	PackBreakdownQty Decimal(18,2),
	IsProfitMarg bit,
	DiscountPercentage Decimal(18,2),
	ProfitMarginPercentage Decimal(18,2)
	)  

	select * from  #Temdata

--declare @actionpass int = 2
	--while exists (select top (1) ItemHeaderID  from #Temdata)
	--begin
		declare @stst int
	

		select top (1) @Id =Id,
						@RateAnalysisHeaderID =RateAnalysisHeaderID ,
						@BoqID = BoqId,
						@SequNo = SequNo ,
						@LocationID = LocationID ,
						@ItemHeaderID =ItemHeaderID ,
						@ItemType=ItemType,
						@UnitID = UnitID,
						@UnitPrice =UnitPrice ,
						@Quantity =Quantity ,
						@ProfitMarginVal =ProfitMarginVal ,
						@OverheadCostVal =OverheadCostVal,
						@isDisRate =isDisRate ,
						@isProjectspecificSubstituteItem =isProjectspecificSubstituteItem ,
						@DisValue=DisValue,
						@IPAddress =IPAddress ,
						@CreatedUserID=CreatedUserID,
						@LastModUserID= LastModUserID,
						@CreatedDate = CreatedDate ,
						@LastModDate = LastModDate ,
						--@Action =1 ,
						@ProjectID = ProjectID ,
						@DeptID = DeptID,
						@PropertyID = PropertyID ,
						@WorkDetailID = WorkDetailID,
						@Currency = Currency,
						@ExchangeRate = ExchangeRate,
						@PackID  = PackID,
						@PackQty =PackQty,
						@PackRate=PackRate,
						@PackBreakdownQty= PackBreakdownQty,
						@IsProfitMarg =IsProfitMarg,
						@DiscountPercentage=DiscountPercentage,
						@ProfitMarginPercentage = ProfitMarginPercentage
						from #Temdata 

						
						


						

	

		exec [SPP_Save_RateAnalysisDetailsForPackage] 
			@Id  ,
			@RateAnalysisHeaderID  ,
			@BoqID  ,
			@SequNo  ,
			@LocationID  ,
			@ItemHeaderID  ,
			@ItemType  ,
			@UnitID  ,
			@UnitPrice  ,
			@Quantity ,
			@ProfitMarginVal  ,
			@OverheadCostVal,
			@isDisRate  ,
			@isProjectspecificSubstituteItem  ,
			@DisValue  ,
			@IPAddress,
			@CreatedUserID  ,
			@LastModUserID  ,
			@CreatedDate  ,
			@LastModDate  ,
			@Action ,
			@stst output,
			@ProjectID,
			1  , --add departmentid here
			@PropertyID  ,
			@WorkDetailID ,
			@Currency ,
			@ExchangeRate,
			@PackID ,
			@PackQty ,
			@PackRate ,
			@PackBreakdownQty,
			@IsProfitMarg,
			@DiscountPercentage,
			@ProfitMarginPercentage

	select scope_identity()

	--delete from #Temdata where ItemHeaderID= @ItemHeaderID
	--EXEC sp_xml_removedocument @docID
	SET @status =1
	
	--end	





--COMMIT TRANSACTION trans1
--SET @status =1
--END TRY
--   BEGIN CATCH
--   ROLLBACK TRAN trans1--RollBack in case of Error
--     DECLARE @message VARCHAR(MAX)
--     SET @status = -1;
--	 SET @message = ERROR_MESSAGE() 
--	 --RAISERROR (15600,-1,-1, @message);
--END CATCH 

GO

