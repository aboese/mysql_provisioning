update provisioning.user_delta set password=password(md5(concat(day(now())+7,' ',month(now())+7,' ',year(now())+7))) where password='';
