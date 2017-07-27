var exec = cordova.require('cordova/exec');
var getpictures={
GetPictures:function(success,error,type){
    exec(success,error,"GetPictures","getAllPictures",[type]);
}
}
module.exports=getpictures;
