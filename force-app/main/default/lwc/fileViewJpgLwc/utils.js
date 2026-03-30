/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
 * Util methods
 */
const CUSTOM_PART = "--c";
// const DOWNLOAD_PART = ".documentforce.com/sfc/servlet.shepherd/document/download/";
const DOWNLOAD_PART = "/sfc/servlet.shepherd/document/download/";

// Returns either an empty string or the org's base video download url
export function getBaseVideoUrl(baseUrl) {
  if (baseUrl) {
    // const domain = baseUrl.split(".")[0];
    const domain = 'https://' + baseUrl;
    // return `${domain}${CUSTOM_PART}${DOWNLOAD_PART}`;
    return `${domain}${DOWNLOAD_PART}`;
  }
  return "";
}