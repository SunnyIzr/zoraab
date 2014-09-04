var BraintreeRecController = {
  init: function(){
    this.braintreeDisbCheckBox()
    this.bofaDisbCheckBox()
    this.checkAllBraintree()
    this.checkAllBofa()
    this.markAllRecd()
  },
  braintreeDisbCheckBox: function(){
    $('input[name="bt_disb[]"]').change(function(){
      BraintreeRecModel.addSubtractBraintreeAmts(this)
    })
  },
  bofaDisbCheckBox: function(){
    $('input[name="bofa_disb[]"]').change(function(){
      BraintreeRecModel.addSubtractBofaAmts(this)
    })
  },
  checkAllBraintree: function(){
    $('#all_braintree').change(function(e){
      if(this.checked){
        $.each($('input[name="bt_disb[]"]'),function(k,v){
          this.checked = true
          BraintreeRecModel.addSubtractBraintreeAmts(this)
        })
      }else{
        $.each($('input[name="bt_disb[]"]'),function(k,v){
          this.checked = false
          BraintreeRecModel.addSubtractBraintreeAmts(this)
        })
      }
    })
  },
  checkAllBofa: function(){
    $('#all_bofa').change(function(e){
      if(this.checked){
        $.each($('input[name="bofa_disb[]"]'),function(k,v){
          this.checked = true
          BraintreeRecModel.addSubtractBofaAmts(this)
        })
      }else{
        $.each($('input[name="bofa_disb[]"]'),function(k,v){
          this.checked = false
          BraintreeRecModel.addSubtractBofaAmts(this)
        })
      }
    })
  },
  markAllRecd: function(){
    $('.mark-as-recd').click(function(e){
      e.preventDefault();
      recdItems = $.map($('form').serializeArray(),function(v,i){return v.value})
      $.post(window.location.href,{data: recdItems}, function(res){
        console.log(res)
      },'json')
    })
  }
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
  },
  addSubtractBofaAmts: function(el){
    if(el.checked){
       amt = parseFloat($(el).parent().parent().find('.net-amt').html())
       amt += BraintreeRecModel.currentBofaAmt()
       $('.bofa-total').html(amt.toFixed(2))
       BraintreeRecModel.calcCheck()
      }else{
       amt = parseFloat($(el).parent().parent().find('.net-amt').html())
       amt = BraintreeRecModel.currentBofaAmt() - amt
       $('.bofa-total').html(amt.toFixed(2))
       BraintreeRecModel.calcCheck()
    }
  },
  addSubtractBraintreeAmts: function(el){
    if(el.checked){
       amt = parseFloat($(el).parent().parent().find('.net-amt').html())
       amt += BraintreeRecModel.currentBraintreeAmt()
       $('.braintree-total').html(amt.toFixed(2))
       BraintreeRecModel.calcCheck()
    }else{
       amt = parseFloat($(el).parent().parent().find('.net-amt').html())
       amt = BraintreeRecModel.currentBraintreeAmt() - amt
       $('.braintree-total').html(amt.toFixed(2))
       BraintreeRecModel.calcCheck()
    }
  }
}



