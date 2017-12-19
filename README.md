# HPPasscodeView
<h2>What this plugin can do?</h2>
<b>
Handling the state change of a passcode view is alway the most complex part of coding, it has so many different conditions.<br/>
This plugin will provider you a simple way to create a passcode view, without doing any extra work it will has the ablity to handle all these kind of states change thing, just like the demo below, all you need to do is focusing on ur UI.
</b>
</br>
I had made three different passcode-views to show you how to use this plugin, and what this plugin can do.

![alt tag](https://github.com/shuangyu/HPPasscodeView/blob/master/HPPasscodeView/Resources/demo.gif)

<h2>How to use this plugin?</h2>

Step 1 : set up a passcode storage implementing <b>HPPasscodeStorePolicy</b> , in my demo named <b>HPPasswordStorage</b>.</br>
<br/>
<br/>
Step 2 : create your own passcode view subclass HPPasscodeView.You should implement methods of <b>HPPasscodeViewImp</b> to init your passcodeview.Refer to what I did in <b>HPDotView、HPFixedLengthPasscodeView、HPSecurityInputPasscodeView</b>. It is really easy to use if you don't need a complex interface, like <b>HPSecurityInputPasscodeView</b>.
<br/>
<br/>
Step 3 : <br/>
3.1 connect passcode storage to passcode view by using <i>_passcodeView.passcodeStorePolicy = [HPPasswordStorage defaultStorage]</i>.<br/>
3.2 set up the initial state of passcode view by using <i>_passcodeView.currentStateType = self.type;</i>.Passcode view will know what it will be used for by setting the parameter, such as used for enable passcode、disable passcode、reset passcode、unlock and so on<br/>
</br>
</br>
Step 4 : set up the delegate of passcode view, and implement this protocol in it's holder.Refer to what I did in <b>DemoViewController</b> 
</br>
</br>