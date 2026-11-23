CREATE PROCEDURE [dbo].[SP_CancelInvoice]
    @InvoiceHeaderID INT ,
    @Mode INT ,
    @ID INT OUTPUT ,
    @SettlementMode BIT,
	@UserID INT 
AS
    BEGIN
        DECLARE @HeadID INT
        BEGIN TRY
            BEGIN TRANSACTION


            IF ( @Mode = 1 )
                BEGIN

                    INSERT  INTO dbo.Cancel_InvoiceHeader
                            ( InvoiceNo ,
                              CustomerID ,
                              CustomerName ,
                              InvoiceDate ,
                              DepartmentID ,
                              Location ,
                              TotalValue ,
                              TotalDiscount ,
                              ToatlDiscountType ,
                              ToatlDiscountRate ,
                              ItemDiscountTotal ,
                              TaxTotal ,
                              OtherCharges ,
                              sysDate ,
                              UserID ,
                              PropertyID ,
                              VATNo ,
                              InvoiceMode ,
                              IPAddress ,
                              CreatedUserID ,
                              LastModUserID ,
                              CreatedDate ,
                              LastModDate
                            )
                            SELECT  InvoiceNo ,
                                    CustomerID ,
                                    CustomerName ,
                                    InvoiceDate ,
                                    DepartmentID ,
                                    Location ,
                                    NetTotal ,
                                    TotalDiscount ,
                                    ItemDiscountType ,
                                    ToatlDiscountRate ,
                                    ItemDiscountTotal ,
                                    TaxTotal ,
                                    OtherCharges ,
                                    sysDate ,
                                    @UserID ,
                                    PropertyID ,
                                    VATNo ,
                                    'Original' ,
                                    IPAddress ,
                                    CreatedUserID ,
                                    LastModUserID ,
                                    CreatedDate ,
                                    GETDATE()
                            FROM    dbo.InvoiceHeaders
                            WHERE   ID = @InvoiceHeaderID

		

                    SET @HeadID = SCOPE_IDENTITY()

                    SET @ID = @HeadID

                    INSERT  INTO dbo.Cancel_InvoiceDetail
                            ( InvoiceHeaderID ,
                              ItemID ,
                              QTY ,
                              UnitID ,
                              UnitPrice ,
                              DelievryQTY ,
                              ReturnQty ,
                              AveragePrice ,
                              CostPrice ,
                              TaxGroupID ,
                              TaxValue ,
                              SerialNo ,
                              ItemDiscountValue ,
                              ItemDiscountPercentage ,
                              ItemDiscountType ,                           
                              WarrentyPeriod ,
                              IsPercentageForDiscount ,
                              IPAddress ,
                              CreatedUserID ,
                              LastModUserID ,
                              CreatedDate ,
                              LastModDate
		                    )
                            SELECT  @HeadID ,
                                    ItemID ,
                                    QTY ,
                                    UnitID ,
                                    UnitPrice ,
                                    DelievryQTY ,
                                    ReturnQty ,
                                    AveragePrice ,
                                    CostPrice ,
                                    TaxGroupID ,
                                    TaxValue ,
                                    SerialNo ,
                                    ItemDiscountValue ,
                                    ItemDiscountPercentage ,
                                    ItemDiscountType ,
                                      WarrentyPeriod ,
                                    IsPercentageForDiscount ,
                                    IPAddress ,
                                    CreatedUserID ,
                                    LastModUserID ,
                                    CreatedDate ,
                                    GETDATE()
                            FROM    dbo.InvoiceDetails
                            WHERE   InvoiceHeaderID = @InvoiceHeaderID

                    DECLARE @PropertyID INT ,
                        @LocationID INT 
                    SELECT  @PropertyID = PropertyID ,
                            @LocationID = Location
                    FROM    dbo.InvoiceHeaders
                    WHERE   ID = @InvoiceHeaderID
                    SELECT  *
                    INTO    #TEMPInvoiceDetail
                    FROM    dbo.InvoiceDetails
                    WHERE   InvoiceHeaderID = @InvoiceHeaderID
						
                    DECLARE @TempInvoiceDetailId INT ,
                        @TempItemId INT ,
                        @TempQty DECIMAL ,
                        @TempunitID INT ,
                        @TempAveragePrice DECIMAL 
										
                    WHILE ( SELECT  COUNT(*)
                            FROM    #TEMPInvoiceDetail
                          ) > 0
                        BEGIN   

                            SELECT TOP 1
                                    @TempInvoiceDetailId = ID ,
                                    @TempItemId = ItemID ,
                                    @TempQty = QTY ,
                                    @TempunitID = UnitID ,
                                    @TempAveragePrice = AveragePrice
                            FROM    #TEMPInvoiceDetail
                            ORDER BY ID 		
    
                            EXEC [SP_UpdateStockItemBalance] @PropertyID,
                                @LocationID, @TempItemId, 'GR', @TempQty,
                                @TempunitID, @TempAveragePrice
                            --added to update stockitemdetails
							  UPDATE  StockTransactionDetails
                              SET     Quantity = Quantity - @TempQty
                              WHERE   StockItemID = @TempItemID AND TxnType='I'
                              AND CONVERT(VARCHAR, CreatedDate, 101) = CONVERT(VARCHAR, GETDATE(), 101)


                            DELETE  FROM #TEMPInvoiceDetail
                            WHERE   ID = @TempInvoiceDetailId
                        END
		  



                    DELETE  FROM dbo.InvoiceHeaders
                    WHERE   ID = @InvoiceHeaderID;
                    DELETE  FROM dbo.InvoiceDetails
                    WHERE   InvoiceHeaderID = @InvoiceHeaderID;

                END

            ELSE
                IF ( @Mode = 2 )
                    BEGIN

                        INSERT  INTO dbo.Cancel_InvoiceHeader
                                ( InvoiceNo ,
                                  CustomerID ,
                                  CustomerName ,
                                  InvoiceDate ,
                                  DepartmentID ,
                                  Location ,
                                  TotalValue ,
                                  TotalDiscount ,
                                  ToatlDiscountType ,
                                  ToatlDiscountRate ,
                                  ItemDiscountTotal ,
                                  TaxTotal ,
                                  OtherCharges ,
                                  sysDate ,
                                  UserID ,
                                  PropertyID ,
                                  VATNo ,
                                  InvoiceMode ,
                                  IPAddress ,
                                  CreatedUserID ,
                                  LastModUserID ,
                                  CreatedDate ,
                                  LastModDate
                                )
                                SELECT  InvoiceNo ,
                                        CustomerID ,
                                        CustomerName ,
                                        InvoiceDate ,
                                        DepartmentID ,
                                        Location ,
                                        NetTotal ,
                                        TotalDiscount ,
                                       ItemDiscountType ,
                                        ToatlDiscountRate ,
                                        ItemDiscountTotal ,
                                        TaxTotal ,
                                        OtherCharges ,
                                        sysDate ,
                                        @UserID ,
                                        PropertyID ,
                                        VATNo ,
                                        'Temp' ,
                                        IPAddress ,
                                        CreatedUserID ,
                                        LastModUserID ,
                                        CreatedDate ,
                                        GETDATE()
                                FROM    dbo.Temp_InvoiceHeader
                                WHERE   ID = @InvoiceHeaderID

		

                        SET @HeadID = SCOPE_IDENTITY()
                        SET @ID = @HeadID

                        INSERT  INTO dbo.Cancel_InvoiceDetail
                                ( InvoiceHeaderID ,
                                  ItemID ,
                                  QTY ,
                                  UnitID ,
                                  UnitPrice ,
                                  DelievryQTY ,
                                  ReturnQty ,
                                  AveragePrice ,
                                  CostPrice ,
                                  TaxGroupID ,
                                  TaxValue ,
                                  SerialNo ,
                                  ItemDiscountValue ,
                                  ItemDiscountPercentage ,
                                  ItemDiscountType ,                             
                                  WarrentyPeriod ,
                                  IsPercentageForDiscount ,
                                  IPAddress ,
                                  CreatedUserID ,
                                  LastModUserID ,
                                  CreatedDate ,
                                  LastModDate
		                        )
                                SELECT  @HeadID ,
                                        ItemID ,
                                        QTY ,
                                        UnitID ,
                                        UnitPrice ,
                                        DelievryQTY ,
                                        ReturnQty ,
                                        AveragePrice ,
                                        CostPrice ,
                                        TaxGroupID ,
                                        TaxValue ,
                                        SerialNo ,
                                        ItemDiscountValue ,
                                        ItemDiscountPercentage ,
                                        ItemDiscountType ,                                        
                                        WarrentyPeriod ,
                                        IsPercentageForDiscount ,
                                        IPAddress ,
                                        CreatedUserID ,
                                        LastModUserID ,
                                        CreatedDate ,
                                        GETDATE()
                                FROM    dbo.Temp_InvoiceDetail
                                WHERE   InvoiceHeaderID = @InvoiceHeaderID

                        IF ( @SettlementMode = 1 )
                            BEGIN
                                DECLARE @PropertyID1 INT ,
                                    @LocationID1 INT 
                                SELECT  @PropertyID1 = PropertyID ,
                                        @LocationID1 = Location
                                FROM    dbo.Temp_InvoiceHeader
                                WHERE   ID = @InvoiceHeaderID
                                SELECT  *
                                INTO    #TEMPInvoiceDetail1
                                FROM    dbo.Temp_InvoiceDetail
                                WHERE   InvoiceHeaderID = @InvoiceHeaderID
						
                                DECLARE @TempInvoiceDetailId1 INT ,
                                    @TempItemId1 INT ,
                                    @TempQty1 DECIMAL ,
                                    @TempunitID1 INT ,
                                    @TempAveragePrice1 DECIMAL 
										
                                WHILE ( SELECT  COUNT(*)
                                        FROM    #TEMPInvoiceDetail1
                                      ) > 0
                                    BEGIN   

                                        SELECT TOP 1
                                                @TempInvoiceDetailId1 = ID ,
                                                @TempItemId1 = ItemID ,
                                                @TempQty1 = QTY ,
                                                @TempunitID1 = UnitID ,
                                                @TempAveragePrice1 = AveragePrice
                                        FROM    #TEMPInvoiceDetail1
                                        ORDER BY ID 		
    
                                        EXEC [SP_UpdateStockItemBalance] @PropertyID1,
                                            @LocationID1, @TempItemId1, 'GR',
                                            @TempQty1, @TempunitID1,
                                            @TempAveragePrice1

									  UPDATE  StockTransactionDetails
                                      SET     Quantity = Quantity - @TempQty1									  
                                      WHERE   StockItemID = @TempItemID1 AND TxnType='I' 
                                      AND CONVERT(VARCHAR, CreatedDate, 101) = CONVERT(VARCHAR, GETDATE(), 101)

                                        DELETE  FROM #TEMPInvoiceDetail1
                                        WHERE   ID = @TempInvoiceDetailId1
                                    END


                            END
                                
                        
	 




                        DELETE  FROM dbo.Temp_InvoiceHeader
                        WHERE   ID = @InvoiceHeaderID;
                        DELETE  FROM dbo.Temp_InvoiceDetail
                        WHERE   InvoiceHeaderID = @InvoiceHeaderID;

                    END

					

            COMMIT TRAN 
        END TRY
        BEGIN CATCH
            RETURN CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
            IF @@TRANCOUNT > 0
                ROLLBACK TRAN 
				
        END CATCH




	
    END

GO

