# UshurSDK

This SDK facilitates communication with the UshurSDK API and can be used in iOS applications.

## Installing and Importing Packages

![Screenshot 2023-06-08 at 4 34 19 PM](https://github.com/UshurInc/UshurMobileSDK/assets/83643420/7963ccec-1b80-4d25-987f-a7e758f68a3d)

![Screenshot 2023-06-08 at 4 34 39 PM](https://github.com/UshurInc/UshurMobileSDK/assets/83643420/5444d662-88c3-4e1a-9fe0-ff8f3c3dd2aa)

Paste https://github.com/UshurInc/UshurSDK-iOS-Samples.git in the search box.

![Screenshot 2023-06-12 at 1 43 03 PM](https://github.com/UshurInc/UshurSDK-iOS-Samples/assets/83643420/ad24793b-39f0-4cce-b52e-027df0c39832)

![Screenshot 2023-06-08 at 4 35 57 PM](https://github.com/UshurInc/UshurMobileSDK/assets/83643420/7172485f-6401-48c8-bf28-0f9f1d0f1578)

![Screenshot 2023-06-12 at 1 54 29 PM](https://github.com/UshurInc/UshurSDK-iOS-Samples/assets/83643420/3eb2b3cc-fcfc-4d3f-8fde-faec45a94f9f)

After installation, the SDK shows up in the package directory in your project sidebar.

![Screenshot 2023-06-12 at 1 56 13 PM](https://github.com/UshurInc/UshurSDK-iOS-Samples/assets/83643420/6cb870d8-2406-439d-8683-db31c72a9a80)

## Using the UshurSDK

Below are the details about classes and methods with their description and usage.

First you need to import UshurSDK in your UIViewController.

![Screenshot 2023-06-12 at 1 57 20 PM](https://github.com/UshurInc/UshurSDK-iOS-Samples/assets/83643420/7d06091b-7f84-49b7-99dc-7862cf2f05aa)

After that you need to initiate the UshurSDK in your UIViewController.

![Screenshot 2023-06-12 at 1 58 48 PM](https://github.com/UshurInc/UshurSDK-iOS-Samples/assets/83643420/2f872880-4ab3-46ed-b25c-8a32aef575d7)

Once you initiate the UshurSDK then you need to pass the delegate to it.

![Screenshot 2023-06-12 at 1 58 59 PM](https://github.com/UshurInc/UshurSDK-iOS-Samples/assets/83643420/20d6fad9-1dc5-4d23-bf11-91b9c013b4f8)

Once you pass the delegate then you need to implement the functions of the delegates in your UIViewController.

![242253238-a4d38224-2147-4e7d-ac3d-1da80d522313](https://github.com/UshurInc/UshurMobileSDK/assets/83643420/b7ab86c8-f630-422e-b514-83244763675b)

Then when ever we need to call the UshurSDK then you need to call the following function -

![Screenshot 2023-06-12 at 2 00 51 PM](https://github.com/UshurInc/UshurSDK-iOS-Samples/assets/83643420/23ae59a1-bd8d-47d0-b3aa-a4f80bc841f8)

    processDocument(imageDataArray: [Data],
                                       emailServiceId: String,
                                       emailSubject: String,
                                       emailBody: String,
                                       replyTo: String,
                                       tokenId: String,
                                       UeTag: String) 

In this function you need to pass the following data -

Parameters:

 1. imageDataArray: Array of the data. Convert image into the data and without compressing the image quality.

 2. emailServiceId: Email pull keyword to trigger the UshurSDK workflow.

 3. emailSubject: Need to pass Email Subject here.

 4. emailBody: Need to pass Email Body here.

 5. replyTo: Sender's email address needs to be passed here so that if in case UshurSDK wants to reply back to the sender, we will get it from this field.

 6. tokenId: Provided by UshurSDK.

 7. UeTag: Provided by UshurSDK.
   
Returns: This function will not return any data, but it will provide the output via 
## delegate functions didGetResponse(result: Results) 
or if any error encountered it will return through 
## didHaveInvalidInput(errorMessage: String)
or if any image is larger or smaller in size then the valid size it will return through 
## invalidImageSizeIndex(indexOfImage: Int)

## Reporting Events

Reporting events are done with the following methods.

![242253198-6342c0a2-f47e-4d53-8086-107c393fc730](https://github.com/UshurInc/UshurMobileSDK/assets/83643420/3c129c75-6ea6-4207-b4cc-190e73279fbe)

***
<p align="center">Copyright 2023. All rights reserved.</p>
