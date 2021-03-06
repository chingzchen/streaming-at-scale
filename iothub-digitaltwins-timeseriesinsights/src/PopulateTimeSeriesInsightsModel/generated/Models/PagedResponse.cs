// <auto-generated>
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for
// license information.
//
// Code generated by Microsoft (R) AutoRest Code Generator.
// Changes may cause incorrect behavior and will be lost if the code is
// regenerated.
// </auto-generated>

namespace Microsoft.Azure.TimeSeriesInsights.Models
{
    using Newtonsoft.Json;
    using System.Linq;

    /// <summary>
    /// Partial result that has continuation token to fetch the next partial
    /// result.
    /// </summary>
    public partial class PagedResponse
    {
        /// <summary>
        /// Initializes a new instance of the PagedResponse class.
        /// </summary>
        public PagedResponse()
        {
            CustomInit();
        }

        /// <summary>
        /// Initializes a new instance of the PagedResponse class.
        /// </summary>
        /// <param name="continuationToken">If returned, this means that
        /// current results represent a partial result. Continuation token
        /// allows to get the next page of results. To get the next page of
        /// query results, send the same request with continuation token
        /// parameter in "x-ms-continuation" HTTP header.</param>
        public PagedResponse(string continuationToken = default(string))
        {
            ContinuationToken = continuationToken;
            CustomInit();
        }

        /// <summary>
        /// An initialization method that performs custom operations like setting defaults
        /// </summary>
        partial void CustomInit();

        /// <summary>
        /// Gets if returned, this means that current results represent a
        /// partial result. Continuation token allows to get the next page of
        /// results. To get the next page of query results, send the same
        /// request with continuation token parameter in "x-ms-continuation"
        /// HTTP header.
        /// </summary>
        [JsonProperty(PropertyName = "continuationToken")]
        public string ContinuationToken { get; private set; }

    }
}
