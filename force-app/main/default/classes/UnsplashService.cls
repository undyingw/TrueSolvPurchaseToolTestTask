public with sharing class UnsplashService {
    @AuraEnabled
    public static String getImageUrl(String query) {
        if (String.isBlank(query)) return null;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Unsplash/search/photos?page=1&per_page=1&query=' + EncodingUtil.urlEncode(query, 'UTF-8'));
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> json = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> results = (List<Object>) json.get('results');
            if (!results.isEmpty()) {
                Map<String,Object> first = (Map<String,Object>) results[0];
                Map<String,Object> urls = (Map<String,Object>) first.get('urls');
                return (String) urls.get('regular');
            }
        }
        return null;
    }
}