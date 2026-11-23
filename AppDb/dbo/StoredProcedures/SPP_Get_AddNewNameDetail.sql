

--[dbo].[SPP_Get_AddNewNameDetail] '<AddNewNameRateHeaderAndDetail xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Id>8</Id><BOQID>1</BOQID><ProjectID>3</ProjectID><DepID>1</DepID><Action>1</Action><WorkID>3</WorkID><RateCode>0</RateCode><ProfitMarginPer>0</ProfitMarginPer><ProfitMarginVal>0</ProfitMarginVal><OverheadCostPer>0</OverheadCostPer><OverheadCostVal>0</OverheadCostVal><TotalCost>0</TotalCost><IPAddress /><CreatedUserID>0</CreatedUserID><LastModUserID>0</LastModUserID><CreatedDate>2018-10-19T07:21:32.442Z</CreatedDate><LastModDate>2018-10-19T07:21:32.442Z</LastModDate><RateDetails><RateAnalysisDetailsmodel><Id>1</Id><RateAnalysisHeaderID>1</RateAnalysisHeaderID><SequNo>1</SequNo><LocationID>4</LocationID><ItemHeaderID>282</ItemHeaderID><ItemType>I</ItemType><UnitID>3</UnitID><UnitPrice>66650</UnitPrice><Quantity>2</Quantity><ProfitMarginVal>0</ProfitMarginVal><OverheadCostVal>0</OverheadCostVal><isDisRate>false</isDisRate><DisValue>0</DisValue><ItemName>AIR CONDITION UNIT 12000 BTU/H</ItemName><Name>NUMBERS</Name><isProjectspecificSubstituteItem>false</isProjectspecificSubstituteItem></RateAnalysisDetailsmodel></RateDetails></AddNewNameRateHeaderAndDetail>'
--[dbo].[SPP_Get_AddNewNameDetail]'<AddNewNameRateHeaderAndDetail xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Id>2</Id><BOQID>1</BOQID><ProjectID>3</ProjectID><DepID>1</DepID><Action>1</Action><WorkID>2</WorkID><RateCode>0</RateCode><ProfitMarginPer>0</ProfitMarginPer><ProfitMarginVal>0</ProfitMarginVal><OverheadCostPer>0</OverheadCostPer><OverheadCostVal>0</OverheadCostVal><TotalCost>0</TotalCost><IPAddress /><CreatedUserID>0</CreatedUserID><LastModUserID>0</LastModUserID><CreatedDate>2018-10-23T05:03:18.325Z</CreatedDate><LastModDate>2018-10-23T05:03:18.325Z</LastModDate><RateDetails><RateAnalysisDetailsmodel><Id>1</Id><RateAnalysisHeaderID>2</RateAnalysisHeaderID><SequNo>1</SequNo><LocationID>5</LocationID><ItemHeaderID>56</ItemHeaderID><ItemType>I</ItemType><UnitID>7</UnitID><UnitPrice>4739.12</UnitPrice><Quantity>2</Quantity><ProfitMarginVal>0</ProfitMarginVal><OverheadCostVal>0</OverheadCostVal><isDisRate>false</isDisRate><DisValue>0</DisValue><ItemName>A1 PAPER</ItemName><Name>PACKET</Name><isProjectspecificSubstituteItem>false</isProjectspecificSubstituteItem></RateAnalysisDetailsmodel></RateDetails></AddNewNameRateHeaderAndDetail>'
CREATE PROCEDURE [dbo].[SPP_Get_AddNewNameDetail] @XMLDetails AS XML
AS
    DECLARE @iDocID INT 
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION
            EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

			
            SELECT  *
            INTO    #TEMP1
            FROM    OPENXML (@iDocID,'AddNewNameRateHeaderAndDetail',2)
WITH (Id INT,BOQID INT,ProjectID INT,DepID INT,Action INT,WorkID INT,RateCode INT )






--INSERT INTO #TEMP(Id,RateAnalysisHeaderID,SequNo,LocationID,ItemHeaderID,ItemType,UnitID,UnitPrice,Quantity,ProfitMarginVal ,
--OverheadCostVal,isDisRate ,DisValue,ItemName,Name ,isProjectspecificSubstituteItem )
            SELECT  Id ,
                    RateAnalysisHeaderID,
                    SequNo ,
                    LocationID ,
                    ItemHeaderID ,
                    ItemType ,
                    UnitID ,
                    UnitPrice ,
                    Quantity ,
                    ProfitMarginVal ,
                    OverheadCostVal ,
                    isDisRate ,
                    DisValue ,
                    ItemName ,
                    Name ,
                    isProjectspecificSubstituteItem
            INTO    #TEMP2
            FROM    OPENXML (@iDocID,'AddNewNameRateHeaderAndDetail/RateDetails/RateAnalysisDetailsmodel',2) 
WITH (Id INT,RateAnalysisHeaderID INT,SequNo INT,LocationID INT,ItemHeaderID INT,ItemType VARCHAR(255),UnitID INT,UnitPrice DECIMAL,Quantity DECIMAL,ProfitMarginVal DECIMAL,
OverheadCostVal DECIMAL,isDisRate BIT,DisValue DECIMAL,ItemName VARCHAR(255),Name VARCHAR(255),isProjectspecificSubstituteItem BIT)

            UPDATE  #TEMP2
            SET     Id = -1
            SELECT  *
            FROM    #TEMP2

            SELECT  *
            FROM    #TEMP1


            DECLARE @Id INT ,
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
                @Action INT ,
                @status INT ,
                @ProjectID INT ,
                @DeptID INT ,
                @PropertyID INT ,
                @WorkDetailID INT


  --@ProjectID 
  --  @DeptID 
  --  @PropertyID 
  --  @WorkDetailID 
  -- @BoqID =
   SELECT  @Id = Id ,
                    @RateAnalysisHeaderID = RateAnalysisHeaderID ,
                    @SequNo = SequNo ,
                    @LocationID = LocationID ,
                    @ItemHeaderID = ItemHeaderID ,
                    @ItemType = ItemType ,
                    @UnitID = UnitID ,
                    @UnitPrice = UnitPrice ,
                    @Quantity = Quantity ,
                    @ProfitMarginVal = ProfitMarginVal ,
                    @OverheadCostVal = OverheadCostVal ,
                    @isDisRate = isDisRate ,
                    @isProjectspecificSubstituteItem = isProjectspecificSubstituteItem ,
                    @DisValue = DisValue ,
                    @IPAddress = '' ,
                    @CreatedUserID = 1 ,
                    @LastModUserID = 1 ,
                    @CreatedDate = GETDATE() ,
                    @LastModDate = GETDATE() ,
                    @Action = 1,
                    @status = -1
            FROM    #TEMP2

            SELECT  @ProjectID = ProjectID ,
                    @DeptID = DepID ,
                    @PropertyID = 1 ,
                    @WorkDetailID = WorkID ,
                    @BoqID = BOQID
            FROM    #TEMP1

DECLARE @count INT
SET @count= 0;
	

	
			WHILE(SELECT COUNT(ItemHeaderID) FROM #TEMP2)>0
			BEGIN


			SELECT TOP(1) @Id = Id ,
                    @RateAnalysisHeaderID = RateAnalysisHeaderID ,
                    @SequNo = SequNo ,
                    @LocationID = LocationID ,
                    @ItemHeaderID = ItemHeaderID ,
                    @ItemType = ItemType ,
                    @UnitID = UnitID ,
                    @UnitPrice = UnitPrice ,
                    @Quantity = Quantity ,
                    @ProfitMarginVal = ProfitMarginVal ,
                    @OverheadCostVal = OverheadCostVal ,
                    @isDisRate = isDisRate ,
                    @isProjectspecificSubstituteItem = isProjectspecificSubstituteItem ,
                    @DisValue = DisValue ,
                    @IPAddress = '' ,
                    @CreatedUserID = 1 ,
                    @LastModUserID = 1 ,
                    @CreatedDate = GETDATE() ,
                    @LastModDate = GETDATE() ,
                    @Action = 1,
                    @status = -1
            FROM    #TEMP2 ORDER BY ItemHeaderID


			EXEC SPP_Save_RateAnalysisDetails @Id,@RateAnalysisHeaderID,@BoqID,@SequNo,@LocationID,@ItemHeaderID,@ItemType,@UnitID,@UnitPrice,@Quantity,@ProfitMarginVal,@OverheadCostVal,@isDisRate,@isProjectspecificSubstituteItem,@DisValue,@IPAddress,@CreatedUserID,@LastModUserID,@CreatedDate,@LastModDate,@Action,@status,@ProjectID,@DeptID,@PropertyID,@WorkDetailID
			SET @count = @count+1;
			SELECT 'Count',@count

			DELETE FROM #TEMP2 WHERE ItemHeaderID=@ItemHeaderID


			END


           
			























            COMMIT TRANSACTION


        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRAN --RollBack in case of Error
        END CATCH 





    END

GO

