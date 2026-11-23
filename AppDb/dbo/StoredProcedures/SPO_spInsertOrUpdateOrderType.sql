
CREATE   PROCEDURE [dbo].[SPO_spInsertOrUpdateOrderType]
    @CustomerJson NVARCHAR(MAX),
    @Oparation CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Parse main OrderType data
        SELECT 
            OrderTypeId,
            OrderTypeName,
            IsActive,
            MinimumOrderValue,         
            MinimumAdvancePercentage,  
            PlaceOrderBeforeDays,      
            AmmendmentBeforeDays,       
            PayBeforeDays,             
            OrderApproval,              
            AllowAmendment,            
            CreditLimitApply,           
            AllowDiscounts,
            CancelOrderDocCharge,
            PropertyId,
            UserId
        INTO #TempOrderType
        FROM OPENJSON(@CustomerJson)
        WITH (
            OrderTypeId             INT             '$.OrderTypeId',
            OrderTypeName           NVARCHAR(MAX)   '$.OrderTypeName',
            IsActive                BIT             '$.IsActive',
            MinimumOrderValue       DECIMAL(18,2)   '$.MinimumOrderValue',      
            MinimumAdvancePercentage DECIMAL(18,2)  '$.MinimumAdvancePercentage',
            PlaceOrderBeforeDays    INT             '$.PlaceOrderBeforeDays',    
            AmmendmentBeforeDays    INT             '$.AmmendmentBeforeDays',    
            PayBeforeDays           INT             '$.PayBeforeDays',           
            OrderApproval           BIT             '$.OrderApproval',           
            AllowAmendment          BIT             '$.AllowAmendment',          
            CreditLimitApply        BIT             '$.CreditLimitApply',       
            AllowDiscounts          BIT             '$.AllowDiscounts',
            CancelOrderDocCharge    DECIMAL(18,2)   '$.CancelOrderDocCharge',
            PropertyId              INT             '$.PropertyId',
            UserId                  INT             '$.UserId'
        );

		

        -- Parse CustomerType array
        SELECT 
            ot.OrderTypeId,
            ct.CustomerTypeId,
            ct.CustomerTypeName,
            ct.PriceTypeId,
            ct.OutletWisePrice,
            ct.OutletList
        INTO #TempCustomerType
        FROM OPENJSON(@CustomerJson, '$.CustomerType')
        WITH (
            CustomerTypeId INT '$.CustomerTypeId',
            CustomerTypeName NVARCHAR(100) '$.CustomerTypeName',
            PriceTypeId INT '$.PriceTypeId',
            OutletWisePrice BIT             '$.OutletWisePrice',
            OutletList NVARCHAR(MAX) '$.OutletList' AS JSON
        ) ct
        CROSS JOIN #TempOrderType ot;

		

        -- Parse OutletList array for each CustomerType
        SELECT 
            ct.CustomerTypeId,
            ct.OrderTypeId,
            ol.OutletCode,
            ol.PriceTypeId
        INTO #TempOutletList
        FROM #TempCustomerType ct
        CROSS APPLY OPENJSON(ct.OutletList)
        WITH (
            OutletCode NVARCHAR(50) '$.OutletCode',
            PriceTypeId INT '$.PriceTypeId'
        ) ol;

		

        DECLARE @OrderTypeId INT;
        DECLARE @OrderTypeName NVARCHAR(MAX);
        DECLARE @IsActive BIT;
        DECLARE @PropertyId INT ;
        DECLARE @UserId INT  ;
        DECLARE @MinimumOrderValue      DECIMAL(18,2);   
        DECLARE @MinimumAdvancePerc     DECIMAL(18,2);     
        DECLARE @PlaceOrderBeforeDays   INT;                
        DECLARE @AmmendmentBeforeDays   INT;               
        DECLARE @PayBeforeDays          INT;               
        DECLARE @OrderApproval          BIT;               
        DECLARE @AllowAmendment         BIT;               
        DECLARE @CreditLimitApply       BIT;                
        DECLARE @AllowDiscounts         BIT; 
        DECLARE @CancelOrderDocCharge   DECIMAL(18,2);

        SELECT 
            @OrderTypeId            = OrderTypeId,
            @OrderTypeName          = OrderTypeName,
            @IsActive               = IsActive,
            @MinimumOrderValue      = MinimumOrderValue,        
            @MinimumAdvancePerc     = MinimumAdvancePercentage,
            @PlaceOrderBeforeDays   = PlaceOrderBeforeDays,     
            @AmmendmentBeforeDays   = AmmendmentBeforeDays,     
            @PayBeforeDays          = PayBeforeDays,           
            @OrderApproval          = OrderApproval,            
            @AllowAmendment         = AllowAmendment,           
            @CreditLimitApply       = CreditLimitApply,         
            @AllowDiscounts         = AllowDiscounts,
            @CancelOrderDocCharge   = CancelOrderDocCharge,
            @PropertyId             = PropertyId,
            @UserId                 = UserId
        FROM #TempOrderType;

		
        -- Perform operation based on @Oparation parameter
        IF @Oparation = 'I' -- INSERT
        BEGIN

		
            -- Insert into SPO_OrderType table
            INSERT INTO [dbo].[SPO_OrderType] (
                OrderTypeName, 
                PropertyId, 
                CreatedUserId, 
                CreatedDateTime, 
                EditedUserId, 
                EditedDateTime,
				IsActive,
                MiniumOrderValue,           
                MiniumAdvancePercentage,    
                PlaceOrderBeforeDays,      
                AmmendmentBeforeDays,      
                PayBeforeDays,             
                IsAllowAmendment,          
                IsCreditLimitApply,         
                IsAllowDiscounts,
                IsOrderApproval,
                CancelOrderDocCharge
            )
            VALUES (
                @OrderTypeName, 
                @PropertyId, 
                @UserId, 
                GETDATE(), 
                @UserId, 
                GETDATE(),
				@IsActive,
                @MinimumOrderValue,        
                @MinimumAdvancePerc,       
                @PlaceOrderBeforeDays,     
                @AmmendmentBeforeDays,      
                @PayBeforeDays,           
                @AllowAmendment,            
                @CreditLimitApply,         
                @AllowDiscounts,
                @OrderApproval,
                @CancelOrderDocCharge
            );
            
            SET @OrderTypeId = SCOPE_IDENTITY();

			

            -- Insert into SPO_OrderTypeWiseCustomer
            INSERT INTO [dbo].[SPO_OrderTypeWiseCustomer] (
                CustomerTypeID,
                OrderTypeID,
                PriceTypeID,
                IsNeedApproval,
                IsAllowCredit,
                IsOutletWisePrice
            )
            SELECT 
                CustomerTypeId,
                @OrderTypeId,
                PriceTypeId,
                IsNeedApproval = 0, -- Default value, adjust as needed
                IsAllowCredit = 0,   -- Default value, adjust as needed
                OutletWisePrice
            FROM #TempCustomerType;


			 -- Insert into SPO_OrderTypeWiseCustomer
            INSERT INTO [dbo].[SPO_OrderTypeWiseCustomerWiseOutletWiseDetails] (
                CustomerTypeID,
                OrderTypeID,
				OutletCode,
                PriceTypeID
            )
            SELECT 
                CustomerTypeId,
                @OrderTypeId,
				OutletCode,
                PriceTypeId
            FROM #TempOutletList;



        END
        ELSE IF @Oparation = 'U' -- UPDATE
        BEGIN
            -- Update SPO_OrderType
            UPDATE [dbo].[SPO_OrderType] 
            SET 
                OrderTypeName = @OrderTypeName,
                EditedUserId = @UserId,
                EditedDateTime = GETDATE(),
				IsActive = @IsActive,
                MiniumOrderValue        = @MinimumOrderValue,       
                MiniumAdvancePercentage = @MinimumAdvancePerc,     
                PlaceOrderBeforeDays    = @PlaceOrderBeforeDays,   
                AmmendmentBeforeDays    = @AmmendmentBeforeDays,   
                PayBeforeDays           = @PayBeforeDays,          
                IsAllowAmendment        = @AllowAmendment,         
                IsCreditLimitApply      = @CreditLimitApply,        
                IsAllowDiscounts        = @AllowDiscounts,
                IsOrderApproval         = @OrderApproval,
                CancelOrderDocCharge    = @CancelOrderDocCharge
            WHERE ID = @OrderTypeId;

            -- Delete existing customer type mappings
            DELETE FROM [dbo].[SPO_OrderTypeWiseCustomer] 
            WHERE OrderTypeID = @OrderTypeId;

            -- Insert updated customer type mappings
            INSERT INTO [dbo].[SPO_OrderTypeWiseCustomer] (
                CustomerTypeID,
                OrderTypeID,
                PriceTypeID,
                IsNeedApproval,
                IsAllowCredit,
                IsOutletWisePrice
            )
            SELECT 
                CustomerTypeId,
                @OrderTypeId,
                PriceTypeId,
                IsNeedApproval = 0, -- Default value, adjust as needed
                IsAllowCredit = 0,   -- Default value, adjust as needed
                OutletWisePrice 
            FROM #TempCustomerType;

			DELETE FROM [dbo].[SPO_OrderTypeWiseCustomerWiseOutletWiseDetails] 
            WHERE OrderTypeID = @OrderTypeId;

			 INSERT INTO [dbo].[SPO_OrderTypeWiseCustomerWiseOutletWiseDetails] (
                CustomerTypeID,
                OrderTypeID,
				OutletCode,
                PriceTypeID
            )
            SELECT 
                CustomerTypeId,
                @OrderTypeId,
				OutletCode,
                PriceTypeId
            FROM #TempOutletList;

           

        END

        -- Return the result (ViewModelCustomer)
        SELECT 
        ot.ID AS OrderTypeId,
        ot.OrderTypeName,
        ot.IsActive,
        otwc.CustomerTypeID AS CustomerTypeId,
        ISNULL(ct.CustomerTypeName, '') AS CustomerTypeName,
        otwc.PriceTypeID AS PriceTypeId,
        ISNULL((
            SELECT 
                ol.OutletCode,
                ol.PriceTypeId
            FROM #TempOutletList ol
            WHERE ol.CustomerTypeId = otwc.CustomerTypeID
            FOR JSON PATH
        ), '[]') AS OutletListJSON
    FROM [dbo].[SPO_OrderType] ot
    LEFT JOIN [dbo].[SPO_OrderTypeWiseCustomer] otwc ON ot.ID = otwc.OrderTypeID
    LEFT JOIN #TempCustomerType ct ON otwc.CustomerTypeID = ct.CustomerTypeId
    WHERE ot.ID = @OrderTypeId;

		

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END

GO

