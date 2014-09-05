var BraintreeRecController = {
  init: function(){
    this.braintreeDisbCheckBox()
    this.bofaDisbCheckBox()
    this.checkAllBraintree()
    this.checkAllBofa()
    this.markAllRecd()
    this.checkAllTrans()
    this.btTransCheckBox()
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
  checkAllTrans: function(){
    $('#all_trans').change(function(e){
      if(this.checked){
        $.each($('input[name="bt_trans[]"]'),function(k,v){
          this.checked = true
          BraintreeTransRecModel.addSubtractNetAmts(this)
        })
      }else{
        $.each($('input[name="bt_trans[]"]'),function(k,v){
          this.checked = false
          BraintreeTransRecModel.addSubtractNetAmts(this)
        })
      }
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
  },
  btTransCheckBox: function(){
    $('input[name="bt_trans[]"]').change(function(){
      BraintreeTransRecModel.addSubtractNetAmts(this)
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

var BraintreeTransRecModel = {
  bofaDisbAmt: function(){
    return parseFloat($('.rec-bofa-disb').html())  
  },
  prevVarAmt: function(){
    return parseFloat($('.rec-prev-var').html())  
  },
  capturedAmt: function(){
    return parseFloat($('.rec-captured').html())  
  },
  missingAmt: function(){
    return parseFloat($('.rec-missing').html())  
  },
  unallocAmt: function(){
    return parseFloat($('.rec-unallocated').html())  
  },
  totalBreak: function(){
    return parseFloat($('.rec-total-break').html())  
  },
  unadjBreak: function(){
    return parseFloat($('.rec-unadj-break').html())  
  },
  addSubtractNetAmts: function(el){
    if(el.checked){
       amt = parseFloat($(el).parent().parent().find('.net-amt').html())
       amt += BraintreeTransRecModel.capturedAmt()
       if (isNaN(amt)) {
        missingAmt = parseFloat($(el).parent().parent().find('.bt-net-amt').html())
        missingAmt += BraintreeTransRecModel.missingAmt()
        $('.rec-missing').html(missingAmt.toFixed(2))
       }else{
        $('.rec-captured').html(amt.toFixed(2))
       }
       BraintreeTransRecModel.calcUnallocated()
    }else{
       amt = parseFloat($(el).parent().parent().find('.net-amt').html())
       amt = BraintreeTransRecModel.capturedAmt() - amt
       if (isNaN(amt)){
         missingAmt = parseFloat($(el).parent().parent().find('.bt-net-amt').html())
         missingAmt = BraintreeTransRecModel.missingAmt() - missingAmt
         $('.rec-missing').html(missingAmt.toFixed(2))
       }else{
       $('.rec-captured').html(amt.toFixed(2))
       }
       BraintreeTransRecModel.calcUnallocated()
    }
  },
  calcUnallocated: function(){
    amt = BraintreeTransRecModel.bofaDisbAmt() + BraintreeTransRecModel.prevVarAmt()
    amt = (BraintreeTransRecModel.capturedAmt() + BraintreeTransRecModel.missingAmt() ) - amt
    $('.rec-unallocated').html(amt.toFixed(2))
    
    amt = BraintreeTransRecModel.bofaDisbAmt() + BraintreeTransRecModel.prevVarAmt()
    amt = (BraintreeTransRecModel.capturedAmt()) - amt
    $('.rec-total-break').html(amt.toFixed(2))
    
    amt = BraintreeTransRecModel.bofaDisbAmt()
    amt = (BraintreeTransRecModel.capturedAmt()) - amt
    $('.rec-unadj-break').html(amt.toFixed(2))
  }
}



