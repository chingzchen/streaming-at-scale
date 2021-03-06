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
    using System.Collections;
    using System.Collections.Generic;
    using System.Linq;

    /// <summary>
    /// Time series model settings including model name, Time Series ID
    /// properties and default type ID.
    /// </summary>
    public partial class TimeSeriesModelSettings
    {
        /// <summary>
        /// Initializes a new instance of the TimeSeriesModelSettings class.
        /// </summary>
        public TimeSeriesModelSettings()
        {
            CustomInit();
        }

        /// <summary>
        /// Initializes a new instance of the TimeSeriesModelSettings class.
        /// </summary>
        /// <param name="name">Time series model display name which is shown in
        /// the UX. Examples: "Temperature Sensors", "MyDevices".</param>
        /// <param name="timeSeriesIdProperties">Time series ID properties
        /// defined during environment creation.</param>
        /// <param name="defaultTypeId">Default type ID of the model that new
        /// time series instances will automatically belong to.</param>
        public TimeSeriesModelSettings(string name = default(string), IList<TimeSeriesIdProperty> timeSeriesIdProperties = default(IList<TimeSeriesIdProperty>), string defaultTypeId = default(string))
        {
            Name = name;
            TimeSeriesIdProperties = timeSeriesIdProperties;
            DefaultTypeId = defaultTypeId;
            CustomInit();
        }

        /// <summary>
        /// An initialization method that performs custom operations like setting defaults
        /// </summary>
        partial void CustomInit();

        /// <summary>
        /// Gets time series model display name which is shown in the UX.
        /// Examples: "Temperature Sensors", "MyDevices".
        /// </summary>
        [JsonProperty(PropertyName = "name")]
        public string Name { get; private set; }

        /// <summary>
        /// Gets time series ID properties defined during environment creation.
        /// </summary>
        [JsonProperty(PropertyName = "timeSeriesIdProperties")]
        public IList<TimeSeriesIdProperty> TimeSeriesIdProperties { get; private set; }

        /// <summary>
        /// Gets default type ID of the model that new time series instances
        /// will automatically belong to.
        /// </summary>
        [JsonProperty(PropertyName = "defaultTypeId")]
        public string DefaultTypeId { get; private set; }

    }
}
