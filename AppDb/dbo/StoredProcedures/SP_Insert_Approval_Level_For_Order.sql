CREATE procedure [dbo].[SP_Insert_Approval_Level_For_Order]
(	 @PropertyID int 
   , @LocationID int 
   , @TransactionID int
   , @TransactionHeaderID int
   
 )
as
print '[INV_InsertApprovalLevelForRequest]'
insert into dbo.ApprovalLogs
	   (SeqID,  TransactionID, ApprovalLevelID , TransactionHeaderID,  PropertyID,  LocationID, IsComplete, DocStatus,IPAddress,CreatedUserID,LastModUserID,CreatedDate,LastModDate,ApprovalUserID)
select  SeqID, @TransactionID, ApprovalTypeID , @TransactionHeaderID, @PropertyID, @LocationID,   0       , 'P',IPAddress,CreatedUserID,LastModUserID,CreatedDate,LastModDate,1
from dbo.TransactionWiseApprovalTypes
where PropertyID = @PropertyID 
and LocationID = @LocationID 
and TransactionID =@TransactionID


exec [dbo].[SP_Chek_Approvels_For_Order] @PropertyID,@LocationID,@TransactionID,@TransactionHeaderID

GO

