bool isLiveMode = true;

const String quizBaseUrl = 'http://139.59.32.181:8000/api/v1/';


const String liveServerBaseUrl = "https://staging-v2.viteezy.com/api/v1/";
// const String devServerBaseUrl = "http://139.59.32.181:8050/api/v1/";
const String devServerBaseUrl = "http://167.71.225.133:8050/api/v1/";

String baseUrl = isLiveMode ? liveServerBaseUrl : devServerBaseUrl;

/// OneSignal App ID - replace with your app ID from OneSignal dashboard (Settings > Keys & IDs)
const String oneSignalAppId = 'a11aa583-9068-4e97-a000-8a7fdec981b6';


String googleLogInClientIdAndroid = '26828450688-ds7i8eeulqmvst6m4rp2g3jlj4aqlqf8.apps.googleusercontent.com';
String googleLogInClientIdIos = '26828450688-fjt7osq052h836tk44fl3ehaj4s0u5ak.apps.googleusercontent.com';


String saansTrial = 'saansTrial';
String poppins = 'poppins';
String headline = 'headline';
