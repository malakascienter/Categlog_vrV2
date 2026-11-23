
CREATE FUNCTION [dbo].[AGGR_fnGetItemWiseResNetVal] (@MenuItemID VARCHAR(10), @OrderType VARCHAR(1), @MemberID INT, @ComplimentaryID INT, @IsDiplomat BIT, @AggregatorID INT,@MenuItemPrice  DECIMAL(18,6))         
    RETURNS  DECIMAL(18,6)
AS
    BEGIN 



		DECLARE @ChargeHeaderID INT, @ItemChargeHeaderID INT
		DECLARE @FBPlusPlusRate BIT,  @ResNetVal numeric(18, 6),@IsEnableItemWiseCharges BIT,@IsMembershipConnect BIT,
		@ExecutiveChargeHeaderID INT,@ComplimentaryChargeHeaderID INT, @DiplomatChargeGroupID INT

		SET @FBPlusPlusRate = (SELECT TOP 1 CAST(Value AS BIT) FROM PB_Settings WHERE Code = 'FBPlusPlusRate');
		SET @IsEnableItemWiseCharges = (SELECT TOP 1 CAST(Value AS BIT) FROM PB_Settings WHERE Code = 'IsEnableItemWiseCharges');
		SET @IsMembershipConnect = (SELECT TOP 1 CAST(Value AS BIT) FROM PB_Settings WHERE Code = 'IsMembershipConnect');
		SET @ExecutiveChargeHeaderID = (SELECT TOP 1 CAST(Value AS INT) FROM PB_Settings WHERE Code = 'ExecutiveChargeHeaderID');
		SET @ComplimentaryChargeHeaderID = (SELECT TOP 1 CAST(Value AS INT) FROM PB_Settings WHERE Code = 'ComplimentaryChargeHeaderID');
		SET @DiplomatChargeGroupID = (SELECT TOP 1 CAST(Value AS INT) FROM PB_Settings WHERE Code = 'DiplomatChargeGroupID');

		IF @IsDiplomat = 1
			BEGIN
				SET @ChargeHeaderID = (SELECT TOP(1) ChargeHeaderID FROM Gen_ItemChargeGroupDetail WHERE ItemChargeHeaderID = @DiplomatChargeGroupID AND OrderType = @OrderType)
			END
		ELSE IF @AggregatorID != 0
			BEGIN

			    IF  (@IsEnableItemWiseCharges = 1)
					BEGIN
						SET @ItemChargeHeaderID = (SELECT TOP(1) ItemChargeHeaderID FROM MainMenu WHERE ItemCode = @MenuItemID)
						SET @ChargeHeaderID = (SELECT TOP(1) ChargeHeaderID FROM Gen_ItemChargeGroupDetail WHERE ItemChargeHeaderID = @ItemChargeHeaderID AND OrderType = @OrderType)
					END
				ELSE
					BEGIN
						SET @ChargeHeaderID = (SELECT TOP(1) AggregatorChargeHeaderID FROM POS_Aggregators WHERE ID = @AggregatorID)
					END
				
			END
		ELSE 
			BEGIN
				IF  (@IsEnableItemWiseCharges = 1)
					BEGIN
						SET @ItemChargeHeaderID = (SELECT TOP(1) ItemChargeHeaderID FROM MainMenu WHERE ItemCode = @MenuItemID)
						SET @ChargeHeaderID = (SELECT TOP(1) ChargeHeaderID FROM Gen_ItemChargeGroupDetail WHERE ItemChargeHeaderID = @ItemChargeHeaderID AND OrderType = @OrderType)
					END
				ELSE
					BEGIN
						SET @ChargeHeaderID = (SELECT TOP (1) ChargeHeaderID FROM POSOrderTypes WHERE Code = @OrderType)

						IF (@IsMembershipConnect = 0)
							BEGIN
								IF @MemberID != 0
									BEGIN
										SET @ChargeHeaderID = @ExecutiveChargeHeaderID
									END
							END

						IF @ComplimentaryID != 0
							BEGIN
								SET @ChargeHeaderID = @ComplimentaryChargeHeaderID
							END
					END
				END

	   
		 SELECT @ResNetVal =  ResNetVal
		 FROM Gen_ChargeGroupHeader 
		 WHERE ChargeHeaderID = @ChargeHeaderID
		 
		SET @ResNetVal = (@ResNetVal-1) * 100

		RETURN ISNULL(@ResNetVal,0)


	END

GO

