var BraintreeRecController = {
  init: function(){
    this.braintreeDisbCheckBox()
    this.bofaDisbCheckBox()
  },
  braintreeDisbCheckBox: function(){
    $('input[name="bt_disb"]').change(function(){
      if(this.checked){
       amt = parseFloat($(this).parent().parent().find('.net-amt').html())
       amt += BraintreeRecModel.currentBraintreeAmt()
       $('.braintree-total').html(amt.toFixed(2))
       BraintreeRecModel.calcCheck()
      }else{
       amt = parseFloat($(this).parent().parent().find('.net-amt').html())
       amt = BraintreeRecModel.currentBraintreeAmt() - amt
       $('.braintree-total').html(amt.toFixed(2))
       BraintreeRecModel.calcCheck()
      }
    })
  },
  bofaDisbCheckBox: function(){
    $('input[name="bofa_disb"]').change(function(){
      if(this.checked){
       amt = parseFloat($(this).parent().parent().find('.net-amt').html())
       amt += BraintreeRecModel.currentBofaAmt()
       $('.bofa-total').html(amt.toFixed(2))
       BraintreeRecModel.calcCheck()
      }else{
       amt = parseFloat($(this).parent().parent().find('.net-amt').html())
       amt = BraintreeRecModel.currentBofaAmt() - amt
       $('.bofa-total').html(amt.toFixed(2))
       BraintreeRecModel.calcCheck()
      }
    })
  }, 
}

var BraintreeRecModel = {
  currentBraintreeAmt: function(){
    return parseFloat($('.braintree-total').html())  
  },
  currentBofaAmt: function(){
    return parseFloat($('.bofa-total').html())  
  },
  calcCheck: function(){
    newAmt = this.currentBraintreeAmt() - this.currentBofaAmt()
    $('.check-total').html(newAmt.toFixed(2))
  }
}

var BraintreeRecView = {
  
}