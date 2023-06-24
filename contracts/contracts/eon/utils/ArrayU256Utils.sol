// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library ArrayU256Utils {
    function clone(
        uint256[] memory data
    ) internal pure returns (uint256[] memory) {
        uint256[] memory result = new uint256[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            result[i] = data[i];
        }
        return result;
    }

    function sort(
        uint256[] memory data
    ) internal pure returns (uint256[] memory) {
        quickSort(data, int(0), int(data.length - 1));
        return data;
    }

    /// @dev Sorts an array of integers in ascending order using the quick sort algorithm.
    function quickSort(
        uint256[] memory arr,
        int left,
        int right
    ) internal pure {
        int i = left;
        int j = right;
        if (i == j) return;
        uint256 pivot = arr[uint(left + (right - left) / 2)];
        while (i <= j) {
            while (arr[uint(i)] < pivot) i++;
            while (pivot < arr[uint(j)]) j--;
            if (i <= j) {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j) quickSort(arr, left, j);
        if (i < right) quickSort(arr, i, right);
    }

    /// @dev Remove duplicate elements in the array
    /// @param data The array is sorted
    function unique(
        uint256[] memory data
    ) internal pure returns (uint256[] memory) {
        if (data.length == 0) return data;
        uint256 j = 0;
        for (uint256 i = 1; i < data.length; i++) {
            if (data[j] != data[i]) {
                j++;
                data[j] = data[i];
            }
        }
        uint256[] memory result = new uint256[](j + 1);
        for (uint256 i = 0; i < j + 1; i++) {
            result[i] = data[i];
        }
        return result;
    }

    function append(
        uint256[] memory data,
        uint256[] memory appendData
    ) internal pure returns (uint256[] memory) {
        uint256[] memory result = new uint256[](
            data.length + appendData.length
        );
        for (uint256 i = 0; i < data.length; i++) {
            result[i] = data[i];
        }
        for (uint256 i = 0; i < appendData.length; i++) {
            result[data.length + i] = appendData[i];
        }
        return result;
    }

    function append(
        uint256[][] memory data
    ) internal pure returns (uint256[] memory) {
        uint256 length = 0;
        for (uint256 i = 0; i < data.length; i++) {
            length += data[i].length;
        }
        uint256[] memory result = new uint256[](length);
        uint256 index = 0;
        for (uint256 i = 0; i < data.length; i++) {
            for (uint256 j = 0; j < data[i].length; j++) {
                result[index] = data[i][j];
                index++;
            }
        }
        return result;
    }
}
