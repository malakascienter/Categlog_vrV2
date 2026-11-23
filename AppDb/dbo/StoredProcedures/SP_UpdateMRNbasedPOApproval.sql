

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--SP_UpdateMRNbasedPOApproval '<ArrayOfPOApprovalDataHeaderIDWises xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><POApprovalDataHeaderIDWises><PoDetailID>1336</PoDetailID><PoHeaderID>1281</PoHeaderID><StockItemID>8</StockItemID><StockItemCode>8</StockItemCode><ItemName>C/  TROUSER</ItemName><UnitCode>3</UnitCode><UnitName>Liter</UnitName><RequestedQuantity>111</RequestedQuantity><ApprovedQuantity>10</ApprovedQuantity><ReceivedQuantity>0</ReceivedQuantity><Remarks>added</Remarks><UnitPrice>665</UnitPrice><flag>0</flag><RequestHeaderID>108</RequestHeaderID><RequestionQty>10</RequestionQty></POApprovalDataHeaderIDWises><POApprovalDataHeaderIDWises><PoDetailID>1336</PoDetailID><PoHeaderID>1281</PoHeaderID><StockItemID>8</StockItemID><StockItemCode>8</StockItemCode><ItemName>C/  TROUSER</ItemName><UnitCode>3</UnitCode><UnitName>Liter</UnitName><RequestedQuantity>111</RequestedQuantity><ApprovedQuantity>10</ApprovedQuantity><ReceivedQuantity>0</ReceivedQuantity><Remarks>added</Remarks><UnitPrice>665</UnitPrice><flag>1</flag><RequestHeaderID>104</RequestHeaderID><RequestionQty>101</RequestionQty><DocNo>000076</DocNo></POApprovalDataHeaderIDWises></ArrayOfPOApprovalDataHeaderIDWises>'
--SP_UpdateMRNbasedPOApproval '<ArrayOfPOApprovalDataHeaderIDWises xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><POApprovalDataHeaderIDWises><PoDetailID>1343</PoDetailID><PoHeaderID>1285</PoHeaderID><StockItemID>72</StockItemID><StockItemCode>10</StockItemCode><ItemName>MOVIE C/ TROUSER12</ItemName><UnitCode>4</UnitCode><UnitName>Grame</UnitName><RequestedQuantity>20</RequestedQuantity><ApprovedQuantity>12</ApprovedQuantity><ReceivedQuantity>0</ReceivedQuantity><Remarks>added</Remarks><UnitPrice>380</UnitPrice><flag>1</flag><RequestHeaderID>104</RequestHeaderID><RequestionQty>20</RequestionQty><DocNo>000076</DocNo></POApprovalDataHeaderIDWises></ArrayOfPOApprovalDataHeaderIDWises>'
CREATE PROCEDURE [dbo].[SP_UpdateMRNbasedPOApproval]
	
	( @XMLDetails XML,@UserId int)
AS
BEGIN
declare @iDocID int


EXEC sp_xml_preparedocument @iDocID OUTPUT,@XMLDetails

create table #itemList1 (
id INT IDENTITY(1,1),
PoDetailID int,
PoHeaderID int,
StockItemID int,
StockItemCode int,
ApprovedQuantity int,
RequestHeaderID int,
RequestionQty INT,
DocNo VARCHAR(max)
)

INSERT INTO #itemList1
        ( PoDetailID ,
          PoHeaderID ,
          StockItemID ,
          StockItemCode ,
          ApprovedQuantity ,
          RequestHeaderID ,
		  RequestionQty,
          DocNo
        )
SELECT  PoDetailID ,
          PoHeaderID ,
          StockItemID ,
          StockItemCode ,
          ApprovedQuantity ,
          RequestHeaderID ,
		  RequestionQty,
          DocNo
FROM     OPENXML (@iDocID,'/ArrayOfPOApprovalDataHeaderIDWises/POApprovalDataHeaderIDWises',2)
WITH     (PoDetailID bigint,
PoHeaderID bigint,
StockItemID BIGINT,
StockItemCode BIGINT,
ApprovedQuantity BIGINT,
RequestHeaderID BIGINT,
RequestionQty DECIMAL,
DocNo VARCHAR(max))

-- added 8/6/2018
DECLARE @MaxApprovelevel INT


SELECT @MaxApprovelevel=MAX(ApprovalTypeID) FROM dbo.TransactionWiseApprovalTypes WHERE TransactionID=2
---

WHILE (SELECT count(*) FROM #itemList1)>0
BEGIN
DECLARE @PODetailID INT,@POHeaderID INT ,@StockITEMID INT,@ApprovedQty DECIMAL,@RequestHeaderID INT,@RequestionQty DECIMAL,@DocNO VARCHAR(max)

SELECT  TOP (1)  @POHeaderID = PoHeaderID,
@PODetailID=PoDetailID,
@StockITEMID=StockItemID,
@ApprovedQty=ApprovedQuantity,
@RequestHeaderID=RequestHeaderID,
@RequestionQty=RequestionQty,
@DocNO=DocNo FROM #itemList1 

UPDATE dbo.PoWisePRs SET ApprovedQty=@ApprovedQty WHERE PoHeaderID=@POHeaderID AND  StockItemID=@StockITEMID AND RequestHeaderID=@RequestHeaderID
SELECT @ApprovedQty,@RequestionQty


IF EXISTS(SELECT * FROM dbo.UserWiseApproveLevels WHERE TransactionTypeID=2 AND UserProfileId=@UserId AND ApproveLevelID=@MaxApprovelevel)
        BEGIN
UPDATE dbo.RequestDetails SET IssuedQuantity=IssuedQuantity-(@RequestionQty-@ApprovedQty) WHERE RequestHeaderID=@RequestHeaderID AND StockItemID=@StockITEMID
-- if MRN based update Docstatus

		IF EXISTS(SELECT * FROM dbo.MRNRegistries WHERE RequestionID=@RequestHeaderID)
		BEGIN

		IF(@ApprovedQty<@RequestionQty)
		BEGIN

		UPDATE dbo.RequestHeaders SET DocumentStatus='P' WHERE Id=@RequestHeaderID

		END    
			
		END 

		END 

DELETE FROM #itemList1 
	    WHERE  PoHeaderID=@POHeaderID AND StockItemID=@StockItemID AND PoDetailID=@PODetailID AND RequestHeaderID=@RequestHeaderID


END

	
END

GO

